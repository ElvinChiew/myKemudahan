defmodule MyKemudahan.AssetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyKemudahan.Assets` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> MyKemudahan.Assets.create_category()

    category
  end

  @doc """
  Generate a asset.
  """
  def asset_fixture(attrs \\ %{}) do
    {:ok, asset} =
      attrs
      |> Enum.into(%{
        cost_per_unit: "120.5",
        description: "some description",
        image: "some image",
        name: "some name",
        status: "some status"
      })
      |> MyKemudahan.Assets.create_asset()

    asset
  end

  @doc """
  Generate a asset_tag.
  """
  def asset_tag_fixture(attrs \\ %{}) do
    {:ok, asset_tag} =
      attrs
      |> Enum.into(%{
        serial: "some serial",
        status: "some status",
        tag: "some tag"
      })
      |> MyKemudahan.Assets.create_asset_tag()

    asset_tag
  end
end
