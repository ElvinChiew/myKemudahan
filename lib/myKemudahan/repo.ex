defmodule MyKemudahan.Repo do
  use Ecto.Repo,
    otp_app: :myKemudahan,
    adapter: Ecto.Adapters.Postgres
end
