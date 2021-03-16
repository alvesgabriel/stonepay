defmodule Stonepay.PaymentTest do
  use Stonepay.DataCase

  alias Stonepay.Payment
  import Stonepay.PaymentsFixtures

  describe "accounts" do
    alias Stonepay.Payment.Account

    @update_attrs %{balance: "456.7"}
    @invalid_attrs %{balance: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert account in Payment.list_accounts()
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Payment.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Payment.create_account(account_attrs())
      assert account.balance == Decimal.new("1000.00")
    end

    test "create_account/1 with invalid balance" do
      assert {:error, changeset} = Payment.create_account(%{balance: "-1"})
      assert "balance minimum is zero" in errors_on(changeset).balance
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payment.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Payment.update_account(account, @update_attrs)
      assert account.balance == Decimal.new("456.7")
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Payment.update_account(account, @invalid_attrs)
      assert account == Payment.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Payment.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Payment.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Payment.change_account(account)
    end
  end

  describe "transactions" do
    alias Stonepay.Payment.Transaction

    @invalid_attrs %{type: nil, value: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Payment.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Payment.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Payment.create_transaction(transaction_attrs())

      assert transaction.type == :withdrawal
      assert transaction.value == Decimal.new("42.42")
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payment.create_transaction(@invalid_attrs)
    end

    test "withdraw/1 with valid data creates a withdrawal" do
      new_balance = Decimal.sub(valid_account_balance(), valid_transaction_value())
      assert {:ok, %Transaction{} = transaction} = Payment.withdraw(withdrawal_attrs())
      assert transaction.type == :withdrawal
      assert transaction.value == valid_transaction_value()
      assert transaction.account.balance == new_balance
    end

    test "withdraw/1 with invalid data creates a withdrawal" do
      withdrawal = withdrawal_attrs() |> Map.replace!("user_id", Ecto.UUID.generate())
      assert {:error, %Ecto.ChangeError{}} = Payment.withdraw(withdrawal)
    end

    test "withdraw/1 with value greater than balance" do
      withdrawal =
        withdrawal_attrs() |> Map.replace!("value", Decimal.mult(valid_account_balance, 10))

      {:error, changeset} = Payment.withdraw(withdrawal)
      assert "balance minimum is zero" in errors_on(changeset).balance
    end

    test "transfer/1 with valid creates a transfer" do
      new_balance_debit = Decimal.sub(valid_account_balance(), valid_transaction_value())
      transfer = transfer_attrs()
      assert {:ok, %Transaction{} = transaction} = Payment.transfer(transfer)
      assert transaction.value == valid_transaction_value()
      assert transaction.account.balance == new_balance_debit

      new_balance_credit = Decimal.add(valid_account_balance(), valid_transaction_value())
      account = Payment.get_account_username(transfer["payee_username"])
      assert account.balance == new_balance_credit
    end

    test "transfer/1 with invalid creates a transfer" do
      transfer = transfer_attrs() |> Map.replace!("user_id", Ecto.UUID.generate())
      assert {:error, %Ecto.ChangeError{} = error} = Payment.transfer(transfer)
      assert error.message == "error to do transfer"
    end
  end
end
