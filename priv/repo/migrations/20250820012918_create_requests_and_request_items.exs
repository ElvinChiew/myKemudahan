defmodule MyKemudahan.Repo.Migrations.CreateRequestsAndRequestItems do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :borrow_from, :date
      add :borrow_to, :date
      add :purpose, :text
      add :total_cost, :decimal

      timestamps()
    end

    create table(:request_items) do
      add :quantity, :integer
      add :cost_per_unit, :decimal
      add :request_id, references(:requests, on_delete: :delete_all)
      add :asset_id, references(:assets, on_delete: :nothing)

      timestamps()
    end

    create index(:request_items, [:request_id])
    create index(:request_items, [:asset_id])
  end
end
