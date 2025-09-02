defmodule MyKemudahan.Repo.Migrations.AddRejectionReasonToRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      add :rejection_reason, :text
    end
  end
end
