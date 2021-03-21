defmodule StonepayWeb.UserControllerTest do
  use StonepayWeb.ConnCase, async: true

  import Stonepay.AccountsFixtures

  setup %{conn: conn} do
    token =
      user_fixture()
      |> Stonepay.Accounts.generate_user_api_token()

    conn = put_req_header(conn, "accept", "application/json")
    conn_auth = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, conn_auth: conn_auth}
  end

  describe "POST /api/users/" do
    test "API creates account user", %{conn: conn} do
      user = user_attrs()

      conn =
        post(conn, Routes.user_path(conn, :create), %{
          "user" => user
        })

      response_user = json_response(conn, 201)["user"]

      assert %{"id" => _} = response_user
      assert %{"account" => _} = response_user
      name = user["name"]
      assert %{"name" => ^name} = response_user
      username = user["username"]
      assert %{"username" => ^username} = response_user
      email = user["email"]
      assert %{"email" => ^email} = response_user
      birthday = Date.to_string(user["birthday"])
      assert %{"birthday" => ^birthday} = response_user
      assert %{"balance" => "1000"} = response_user["account"]
    end
  end

  describe "POST /api/users/log_in" do
    test "API log in", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, Routes.user_path(conn, :log_in), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      user_id = user.id
      assert %{"token" => _, "user_id" => ^user_id} = json_response(conn, 200)
    end
  end

  describe "DELETE /api/users/log_out" do
    test "API log out", %{conn_auth: conn_auth} do
      conn_auth = delete(conn_auth, Routes.user_path(conn_auth, :log_out))
      assert %{"message" => "user log out"} = json_response(conn_auth, 200)
    end
  end
end
