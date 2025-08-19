defmodule MyKemudahan.Repo.Migrations.CreateAssetTag do
  use Ecto.Migration

  def change do
    create table(:asset_tag) do
      add :tag, :string
      add :serial, :string
      add :status, :string
      add :asset_id, references(:assets, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:asset_tag, [:asset_id])
  end
end
