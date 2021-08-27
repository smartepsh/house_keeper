defmodule Keeper.Repo do
  use Ecto.Repo,
    otp_app: :house_keeper,
    adapter: Ecto.Adapters.Postgres
end
