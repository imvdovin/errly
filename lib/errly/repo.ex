defmodule Errly.Repo do
  use Ecto.Repo,
    otp_app: :errly,
    adapter: Ecto.Adapters.Postgres
end
