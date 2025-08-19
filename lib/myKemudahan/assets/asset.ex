defmodule MyKemudahan.Assets.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyKemudahan.Assets.Category
  alias MyKemudahan.Assets.AssetTag

  schema "assets" do
    field :name, :string
    field :status, :string
    field :description, :string
    field :image, :string
    field :cost_per_unit, :decimal
    #field :category_id, :id

    belongs_to :category, Category

    has_many :asset_tags, AssetTag, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:name, :description, :cost_per_unit, :image, :category_id])
    |> validate_required([:name, :description, :cost_per_unit, :image, :category_id])
    |> cast_assoc(:asset_tags, with: &MyKemudahan.Assets.AssetTag.changeset/2)
    |> assoc_constraint(:category)
  end
end
