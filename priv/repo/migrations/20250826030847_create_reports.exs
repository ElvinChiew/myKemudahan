defmodule MyKemudahan.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :reported_at, :naive_datetime
      add :quantity, :integer
      add :description, :text
      add :status, :string
      add :reporter_id, references(:users, on_delete: :nothing)
      add :asset_id, references(:assets, on_delete: :nothing)
      add :request_id, references(:requests, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:reports, [:reporter_id])
    create index(:reports, [:asset_id])
    create index(:reports, [:request_id])
  end
end
