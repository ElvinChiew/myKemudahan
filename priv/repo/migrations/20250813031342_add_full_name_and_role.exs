defmodule MyKemudahan.Repo.Migrations.AddFullNameAndRole do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :string
      add :role, :string, default: "user"
    end
  end
end
