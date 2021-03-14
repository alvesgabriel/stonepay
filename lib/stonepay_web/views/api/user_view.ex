defmodule StonepayWeb.UserView do
  use StonepayWeb, :view

  def render("create.json", %{user: user}) do
    %{
      user: %{id: user.id}
    }
  end

  def render("log_in.json", %{user: user, token: token}) do
    %{password_hash: token} = token |> Bcrypt.add_hash()

    %{
      user_id: user.id,
      token: token
    }
  end
end
