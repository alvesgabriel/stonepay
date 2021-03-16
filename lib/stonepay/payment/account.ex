defmodule Stonepay.Payment.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Stonepay.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :balance, :decimal

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def registrations_changeset(account, attrs) do
    account
    |> cast(attrs, [:balance, :user_id])
    |> validate_balance()
    |> validate_user_id()
  end

  defp validate_balance(changeset) do
    changeset
    |> validate_required([:balance])
    |> validate_number(
      :balance,
      greater_than: Decimal.new("0"),
      message: "balance minimum is zero"
    )
  end

  def validate_user_id(changeset) do
    changeset
    |> validate_required([:user_id])
  end
end
