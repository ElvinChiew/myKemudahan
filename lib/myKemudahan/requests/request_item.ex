defmodule MyKemudahan.Requests.RequestItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "request_items" do
    field :quantity, :integer
    field :cost_per_unit,:decimal

    belongs_to :request, MyKemudahan.Requests.Request
    belongs_to :asset, MyKemudahan.Assets.Asset

    timestamps(type: :naive_datetime)
  end

  def changeset(request_item, attrs) do
    request_item
    |> cast(attrs, [:quantity, :cost_per_unit, :asset_id, :request_id])
    |> validate_required([:quantity, :cost_per_unit, :asset_id, :request_id])
  end

end
