defmodule MyKemudahan.Repo.Migrations.AddLateFeeToRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :late_fee, :decimal, default: 0.0
    end
  end
end
