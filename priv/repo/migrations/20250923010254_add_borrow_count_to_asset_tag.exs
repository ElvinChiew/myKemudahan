defmodule MyKemudahan.Repo.Migrations.AddBorrowCountToAssetTag do
  use Ecto.Migration

  def change do
    alter table(:asset_tag) do
      add :borrow_count, :integer, default: 0, null: false
    end
  end
end
