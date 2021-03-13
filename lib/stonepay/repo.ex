defmodule Stonepay.Repo do
  use Ecto.Repo,
    otp_app: :stonepay,
    adapter: Ecto.Adapters.Postgres
end
