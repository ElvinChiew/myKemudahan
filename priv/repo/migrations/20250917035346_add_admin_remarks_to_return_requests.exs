defmodule MyKemudahan.Repo.Migrations.AddAdminRemarksToReturnRequests do
  use Ecto.Migration

  def change do
    alter table(:return_requests) do
      add :admin_remarks, :text
    end
  end
end
