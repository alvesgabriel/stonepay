defmodule Stonepay.Payment.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Stonepay.Payment.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :type, Ecto.Enum, values: [:withdrawal, :debit, :credit]
    field :value, :decimal

    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def registrations_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:value, :type, :account_id])
    |> validate_required([:value, :type, :account_id])
  end
end
