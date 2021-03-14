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
end
