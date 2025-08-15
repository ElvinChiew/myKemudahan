defmodule MyKemudahan.AssetsTest do
  use MyKemudahan.DataCase

  alias MyKemudahan.Assets

  describe "categories" do
    alias MyKemudahan.Assets.Category

    import MyKemudahan.AssetsFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Assets.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Assets.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = Assets.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assets.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Assets.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Assets.update_category(category, @invalid_attrs)
      assert category == Assets.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Assets.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Assets.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Assets.change_category(category)
    end
  end

  describe "assets" do
    alias MyKemudahan.Assets.Asset

    import MyKemudahan.AssetsFixtures

    @invalid_attrs %{name: nil, status: nil, description: nil, image: nil, cost_per_unit: nil}

    test "list_assets/0 returns all assets" do
      asset = asset_fixture()
      assert Assets.list_assets() == [asset]
    end

    test "get_asset!/1 returns the asset with given id" do
      asset = asset_fixture()
      assert Assets.get_asset!(asset.id) == asset
    end

    test "create_asset/1 with valid data creates a asset" do
      valid_attrs = %{name: "some name", status: "some status", description: "some description", image: "some image", cost_per_unit: "120.5"}

      assert {:ok, %Asset{} = asset} = Assets.create_asset(valid_attrs)
      assert asset.name == "some name"
      assert asset.status == "some status"
      assert asset.description == "some description"
      assert asset.image == "some image"
      assert asset.cost_per_unit == Decimal.new("120.5")
    end

    test "create_asset/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assets.create_asset(@invalid_attrs)
    end

    test "update_asset/2 with valid data updates the asset" do
      asset = asset_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", description: "some updated description", image: "some updated image", cost_per_unit: "456.7"}

      assert {:ok, %Asset{} = asset} = Assets.update_asset(asset, update_attrs)
      assert asset.name == "some updated name"
      assert asset.status == "some updated status"
      assert asset.description == "some updated description"
      assert asset.image == "some updated image"
      assert asset.cost_per_unit == Decimal.new("456.7")
    end

    test "update_asset/2 with invalid data returns error changeset" do
      asset = asset_fixture()
      assert {:error, %Ecto.Changeset{}} = Assets.update_asset(asset, @invalid_attrs)
      assert asset == Assets.get_asset!(asset.id)
    end

    test "delete_asset/1 deletes the asset" do
      asset = asset_fixture()
      assert {:ok, %Asset{}} = Assets.delete_asset(asset)
      assert_raise Ecto.NoResultsError, fn -> Assets.get_asset!(asset.id) end
    end

    test "change_asset/1 returns a asset changeset" do
      asset = asset_fixture()
      assert %Ecto.Changeset{} = Assets.change_asset(asset)
    end
  end
end
