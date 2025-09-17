defmodule MyKemudahan.Repo.Migrations.CreateReturnRequests do
  use Ecto.Migration

  def change do
    create table(:return_requests) do
      add :request_id, references(:requests, on_delete: :nothing), null: false
      add :status, :string, default: "pending", null: false
      add :submitted_at, :naive_datetime, null: false
      add :processed_at, :naive_datetime
      add :notes, :text

      timestamps()
    end

    create index(:return_requests, [:request_id])
    create index(:return_requests, [:status])
  end
end
