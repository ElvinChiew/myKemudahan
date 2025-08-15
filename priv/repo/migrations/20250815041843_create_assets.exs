defmodule MyKemudahan.Repo.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create table(:assets) do
      add :name, :string
      add :description, :text
      add :cost_per_unit, :decimal
      add :image, :string
      add :status, :string
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:assets, [:category_id])
  end
end
