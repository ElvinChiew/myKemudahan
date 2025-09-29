defmodule MyKemudahan.Repo.Migrations.CreateSystemLogs do
  use Ecto.Migration

  def change do
    create table(:system_logs) do
      add :admin_id, references(:users, on_delete: :nilify_all)
      add :action, :string, null: false
      add :entity_type, :string, null: false
      add :entity_id, :integer, null: false
      add :details, :text
      add :performed_at, :naive_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:system_logs, [:admin_id])
    create index(:system_logs, [:entity_type, :entity_id])
    create index(:system_logs, [:performed_at])
    create index(:system_logs, [:action])
  end
end
