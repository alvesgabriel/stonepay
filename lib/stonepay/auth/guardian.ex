defmodule Stonepay.Auth.Guardian do
  use Guardian, otp_app: :stonepay

  alias Stonepay.Accounts.User

  def subject_for_token(user = %User{}, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, "Unknown resource type"}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok, Stonepay.Accounts.get_user!(id)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
