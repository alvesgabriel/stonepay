defmodule Stonepay.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stonepay.Payments` context.
  """

  import Stonepay.AccountsFixtures

  def valid_account_balance, do: "1000.00"

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        user_id: user_fixture().id,
        balance: valid_account_balance()
      })
      |> Stonepay.Payment.create_account()

    account
  end

  def account_attrs() do
    %{
      "user_id" => user_fixture().id,
      "balance" => valid_account_balance()
    }
  end

  def valid_transaction_type, do: :withdrawal
  def valid_transaction_value, do: Decimal.new("42.42")

  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        account_id: account_fixture().id,
        type: valid_transaction_type(),
        value: valid_transaction_value()
      })
      |> Stonepay.Payment.create_transaction()

    transaction
  end

  def transaction_attrs() do
    %{
      "account_id" => account_fixture().id,
      "type" => valid_transaction_type(),
      "value" => valid_transaction_value()
    }
  end

  def withdrawal_attrs() do
    %{
      "user_id" => user_fixture().id,
      "value" => valid_transaction_value()
    }
  end

  def transfer_attrs() do
    user = user_fixture()

    %{
      "user_id" => user.id,
      "payee_username" => user_debit().username,
      "value" => valid_transaction_value()
    }
  end
end
