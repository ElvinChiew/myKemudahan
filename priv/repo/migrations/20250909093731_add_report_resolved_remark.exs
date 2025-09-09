defmodule MyKemudahan.Repo.Migrations.AddReportResolvedRemark do
  use Ecto.Migration

  def change do
    alter table(:reports) do
      add :resolution_remark, :text
    end

  end
end
