defmodule MyKemudahan.Repo.Migrations.AddUserFieldToRequest do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :discount_amount, :decimal, default: 0.00
      add :final_cost, :decimal
      add :status, :string, default: "sent"
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:requests, [:user_id])
  end
end
