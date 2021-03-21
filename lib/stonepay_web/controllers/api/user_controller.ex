defmodule StonepayWeb.UserController do
  use StonepayWeb, :controller

  alias Stonepay.Accounts

  def create(conn, %{"user" => user_params}) do
    {:ok, user} = Accounts.register_user(user_params)

    conn
    |> put_status(:created)
    |> render("create.json", user: user)
  end

  def log_in(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.generate_user_api_token(user)

      conn
      |> render("log_in.json", %{user: user, token: token})
    end
  end

  def log_out(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    token = Guardian.Plug.current_token(conn)

    Accounts.delete_api_user_token(token)
    Stonepay.Auth.Guardian.revoke(token)

    conn |> render("log_out.json", %{user: user})
  end
end
