defmodule MyKemudahan.SystemLogs.SystemLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyKemudahan.Accounts.User

  schema "system_logs" do
    field :action, :string
    field :entity_type, :string
    field :entity_id, :integer
    field :details, :string
    field :performed_at, :naive_datetime

    belongs_to :admin, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(system_log, attrs) do
    system_log
    |> cast(attrs, [:admin_id, :action, :entity_type, :entity_id, :details, :performed_at])
    |> validate_required([:admin_id, :action, :entity_type, :entity_id, :performed_at])
    |> assoc_constraint(:admin)
  end
end
