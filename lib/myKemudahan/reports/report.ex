defmodule MyKemudahan.Reports.Report do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyKemudahan.Accounts.User
  alias MyKemudahan.Assets.Asset
  alias MyKemudahan.Requests.Request

  schema "reports" do
    field :status, :string
    field :description, :string
    field :reported_at, :naive_datetime
    field :quantity, :integer

    belongs_to :reporter, User
    belongs_to :asset, Asset
    belongs_to :request, Request

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:reporter_id, :asset_id, :request_id, :reported_at, :quantity, :description, :status])
    |> validate_required([:reporter_id, :asset_id, :reported_at, :quantity, :description, :status])
    |> assoc_constraint(:reporter)
    |> assoc_constraint(:asset)
    |> assoc_constraint(:request)
  end
end
