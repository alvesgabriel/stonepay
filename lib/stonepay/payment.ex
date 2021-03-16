defmodule Stonepay.Payment do
  @moduledoc """
  The Payment context.
  """

  import Ecto.Query, warn: false
  alias Stonepay.Repo

  alias Stonepay.Payment.Account
  alias Stonepay.Payment.Transaction

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)
  def get_account(id), do: Repo.get(Account, id)

  def get_account_user!(user_id), do: Repo.get_by!(Account, :user_id, user_id)
  def get_account_user(user_id), do: Repo.get_by(Account, user_id: user_id)

  def get_account_username(username) do
    from(account in Account,
      inner_join: user in assoc(account, :user),
      where: user.username == ^username,
      preload: [user: user]
    )
    |> Repo.one()

    # Repo.get_by(Account, username: username)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.registrations_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.registrations_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.registrations_changeset(account, attrs)
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    case %Transaction{}
         |> Transaction.registrations_changeset(attrs)
         |> Repo.insert() do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  def withdraw(attrs \\ %{}) do
    value = Decimal.new(attrs["value"])

    case get_account_user(attrs["user_id"]) do
      %Account{} = account ->
        account_update = %{
          balance: Decimal.sub(account.balance, value)
        }

        case Repo.transaction(fn ->
               with {:ok, transfer} <-
                      %{
                        "account_id" => account.id,
                        "type" => :withdrawal,
                        "value" => attrs["value"]
                      }
                      |> create_transaction(),
                    {:ok, %Stonepay.Payment.Account{}} <- update_account(account, account_update) do
                 transfer |> Repo.preload(:account)
               else
                 {:error, error} -> {:error, error}
               end
             end) do
          {:ok, {:error, error}} -> {:error, error}
          {:ok, result} -> {:ok, result}
          {:error, error} -> {:error, error}
        end

      nil ->
        {:error, %Ecto.ChangeError{message: "Account with user id #{attrs["user_id"]} not found"}}
    end
  end

  def transfer(attrs \\ %{}) do
    with %Account{} = debit_account <- get_account_user(attrs["user_id"]),
         %Account{} = credit_account <- get_account_username(attrs["payee_username"]) do
      value = Decimal.new(attrs["value"])

      debit = %{
        "value" => value,
        "account_id" => debit_account.id,
        "type" => :debit
      }

      debit_attrs = %{
        balance: Decimal.sub(debit_account.balance, value)
      }

      credit = %{
        "value" => value,
        "account_id" => credit_account.id,
        "type" => :credit
      }

      credit_attrs = %{
        balance: Decimal.add(debit_account.balance, value)
      }

      Repo.transaction(fn ->
        with {:ok, debit_transaction} <- create_transaction(debit),
             {:ok, _} <- update_account(debit_account, debit_attrs),
             {:ok, _} <- create_transaction(credit),
             {:ok, _} <- update_account(credit_account, credit_attrs) do
          debit_transaction |> Repo.preload(:account)
        else
          {:error, error} -> {:error, error}
        end
      end)
    else
      nil -> {:error, %Ecto.ChangeError{message: "error to do transfer"}}
    end
  end
end
