defmodule StonepayWeb.TransactionController do
  use StonepayWeb, :controller

  alias Stonepay.Payment
  alias Stonepay.Payment.Transaction

  action_fallback StonepayWeb.FallbackController

  def index(conn, _params) do
    transactions = Payment.list_transactions()
    render(conn, "index.json", transactions: transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <- Payment.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Payment.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end

  def withdraw(conn, %{"transaction" => %{"value" => value}}) do
    user = Guardian.Plug.current_resource(conn)

    transaction_params = %{
      "value" => value,
      "user_id" => user.id
    }

    {:ok, withdrawal} = Payment.withdraw(transaction_params)
    render(conn, "withdraw.json", withdrawal: withdrawal)
  end

  def transfer(conn, %{"transaction" => %{"payee_username" => payee_username, "value" => value}}) do
    user = Guardian.Plug.current_resource(conn)

    transaction_params = %{
      "user_id" => user.id,
      "payee_username" => payee_username,
      "value" => value
    }

    {:ok, transfer} = Payment.transfer(transaction_params)
    render(conn, "transfer.json", transfer: transfer)
  end
end
