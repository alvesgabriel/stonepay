defmodule StonepayWeb.TransactionControllerTest do
  use StonepayWeb.ConnCase
  import Stonepay.AccountsFixtures
  import Stonepay.PaymentsFixtures

  alias Stonepay.Payment

  setup %{conn: conn} do
    token =
      user_fixture()
      |> Stonepay.Accounts.generate_user_api_token()

    conn = put_req_header(conn, "accept", "application/json")
    conn_auth = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, conn_auth: conn_auth}
  end

  describe "GET /users/transactions" do
    test "lists all transactions unauthenticated", %{conn: conn} do
      conn = get(conn, Routes.transaction_path(conn, :index))
      assert json_response(conn, 401) == %{"message" => "unauthenticated"}
    end

    test "lists all transactions", %{conn_auth: conn_auth} do
      conn_auth = get(conn_auth, Routes.transaction_path(conn_auth, :index))
      assert json_response(conn_auth, 200)["data"] == []
    end
  end

  describe "GET /users/transactions/:id" do
    test "show one transaction unauthenticated", %{conn: conn} do
      transaction = transaction_fixture()
      conn = get(conn, Routes.transaction_path(conn, :show, transaction.id))
      assert json_response(conn, 401) == %{"message" => "unauthenticated"}
    end

    test "show one transaction", %{conn_auth: conn_auth} do
      transaction = transaction_fixture()
      conn_auth = get(conn_auth, Routes.transaction_path(conn_auth, :show, transaction.id))
      response = json_response(conn_auth, 200)
      assert transaction.id == response["data"]["id"]
      assert to_string(transaction.value) == response["data"]["value"]
    end
  end

  describe "POST /users/transactions/withdraw" do
    test "withdraw value unauthenticated", %{conn: conn} do
      transaction = withdrawal_attrs()
      conn = post(conn, Routes.transaction_path(conn, :withdraw), %{"transaction" => transaction})
      assert json_response(conn, 401) == %{"message" => "unauthenticated"}
    end

    test "withdraw one value", %{conn_auth: conn_auth} do
      transaction = withdrawal_attrs()

      new_balance =
        account_attrs()["balance"]
        |> Decimal.sub(transaction["value"])
        |> to_string()

      conn_auth =
        post(conn_auth, Routes.transaction_path(conn_auth, :withdraw), %{
          "transaction" => transaction
        })

      response = json_response(conn_auth, 200)["data"]
      assert %{"id" => _} = response
      assert to_string(transaction["value"]) == response["value"]
      assert "withdrawal" == response["type"]
      assert new_balance == response["account"]["balance"]
    end
  end

  describe "POST /users/transactions/transfer" do
    test "transfer value unauthanticated", %{conn: conn} do
      transaction = transfer_attrs()
      conn = post(conn, Routes.transaction_path(conn, :transfer), %{"transaction" => transaction})
      assert json_response(conn, 401) == %{"message" => "unauthenticated"}
    end

    test "transfer one value", %{conn_auth: conn_auth} do
      transaction = transfer_attrs()

      payee_user = Payment.get_account_username(transaction["payee_username"])

      payee_balance = Decimal.add(payee_user.balance, transaction["value"])

      payer_balance =
        account_attrs()["balance"]
        |> Decimal.sub(transaction["value"])
        |> to_string()

      conn_auth =
        post(conn_auth, Routes.transaction_path(conn_auth, :transfer), %{
          "transaction" => transaction
        })

      new_payee_balance =
        Payment.get_account(payee_user.id)
        |> Map.get(:balance)

      response = json_response(conn_auth, 200)["data"]
      assert %{"id" => _} = response
      assert "debit" == response["type"]
      assert to_string(transaction["value"]) == response["value"]
      assert payer_balance == response["account"]["balance"]
      assert payee_balance == new_payee_balance
    end
  end
end
