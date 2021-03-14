defmodule StonepayWeb.UserControllerTest do
  use StonepayWeb.ConnCase, async: true

  import Stonepay.AccountsFixtures

  describe "POST /api/users/" do
    test "API creates account user", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), %{
          "user" => user_attrs()
        })

      assert %{"id" => _} = json_response(conn, 201)["user"]
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
end
