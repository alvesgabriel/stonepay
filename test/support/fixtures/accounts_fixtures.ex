defmodule Stonepay.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stonepay.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_user_username, do: "user#{System.unique_integer([:positive])}"
  def valid_user_name, do: "Minch Yoda"
  def valid_user_birthday, do: ~D[1942-01-01]
  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: unique_user_username(),
        name: valid_user_name(),
        birthday: valid_user_birthday(),
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> Stonepay.Accounts.register_user()

    user
  end

  def user_attrs() do
    %{
      "email" => unique_user_email(),
      "password" => valid_user_password(),
      "username" => unique_user_username(),
      "name" => valid_user_name(),
      "birthday" => valid_user_birthday()
    }
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
