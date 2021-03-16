defmodule StonepayWeb.TransactionView do
  use StonepayWeb, :view
  alias StonepayWeb.TransactionView
  alias Stonepay.Payment.Transaction

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      value: transaction.value,
      type: transaction.type
    }
  end

  def render("withdraw.json", %{withdrawal: withdrawal}) do
    %{data: transaction_response(withdrawal)}
  end

  def render("transfer.json", %{transfer: transfer}) do
    %{data: transaction_response(transfer)}
  end

  defp transaction_response(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      value: transaction.value,
      type: transaction.type,
      account: %{
        account_id: transaction.account.id,
        balance: transaction.account.balance
      }
    }
  end
end
