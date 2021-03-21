defmodule StonepayWeb.UserView do
  use StonepayWeb, :view

  def render("create.json", %{user: user}) do
    %{
      user: %{
        id: user.id,
        name: user.name,
        username: user.username,
        email: user.email,
        birthday: user.birthday,
        account: %{
          id: user.account.id,
          balance: user.account.balance
        }
      }
    }
  end

  def render("log_in.json", %{user: user, token: token}) do
    %{password_hash: token} = token |> Bcrypt.add_hash()

    %{
      user_id: user.id,
      token: token
    }
  end

  def render("log_out.json", %{user: user}) do
    %{
      user_id: user.id,
      message: "user log out"
    }
  end
end
