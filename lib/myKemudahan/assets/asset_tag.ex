defmodule MyKemudahan.Assets.AssetTag do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyKemudahan.Assets.Asset

  schema "asset_tag" do
    field :serial, :string
    field :status, :string
    field :tag, :string
    #field :asset_id, :id

    belongs_to :asset, Asset

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(asset_tag, attrs) do
    asset_tag
    |> cast(attrs, [:tag, :serial, :status])
    |> validate_required([:tag, :serial])
    |> put_change(:status, attrs["status"] || "active")
  end
end
