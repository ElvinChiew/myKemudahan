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

  describe "asset_tags" do
    alias MyKemudahan.Assets.AssetTag

    import MyKemudahan.AssetsFixtures

    @invalid_attrs %{serial: nil, status: nil, tag: nil}

    test "list_asset_tags/0 returns all asset_tags" do
      asset_tag = asset_tag_fixture()
      assert Assets.list_asset_tags() == [asset_tag]
    end

    test "get_asset_tag!/1 returns the asset_tag with given id" do
      asset_tag = asset_tag_fixture()
      assert Assets.get_asset_tag!(asset_tag.id) == asset_tag
    end

    test "create_asset_tag/1 with valid data creates a asset_tag" do
      valid_attrs = %{serial: "some serial", status: "some status", tag: "some tag"}

      assert {:ok, %AssetTag{} = asset_tag} = Assets.create_asset_tag(valid_attrs)
      assert asset_tag.serial == "some serial"
      assert asset_tag.status == "some status"
      assert asset_tag.tag == "some tag"
    end

    test "create_asset_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assets.create_asset_tag(@invalid_attrs)
    end

    test "update_asset_tag/2 with valid data updates the asset_tag" do
      asset_tag = asset_tag_fixture()
      update_attrs = %{serial: "some updated serial", status: "some updated status", tag: "some updated tag"}

      assert {:ok, %AssetTag{} = asset_tag} = Assets.update_asset_tag(asset_tag, update_attrs)
      assert asset_tag.serial == "some updated serial"
      assert asset_tag.status == "some updated status"
      assert asset_tag.tag == "some updated tag"
    end

    test "update_asset_tag/2 with invalid data returns error changeset" do
      asset_tag = asset_tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Assets.update_asset_tag(asset_tag, @invalid_attrs)
      assert asset_tag == Assets.get_asset_tag!(asset_tag.id)
    end

    test "delete_asset_tag/1 deletes the asset_tag" do
      asset_tag = asset_tag_fixture()
      assert {:ok, %AssetTag{}} = Assets.delete_asset_tag(asset_tag)
      assert_raise Ecto.NoResultsError, fn -> Assets.get_asset_tag!(asset_tag.id) end
    end

    test "change_asset_tag/1 returns a asset_tag changeset" do
      asset_tag = asset_tag_fixture()
      assert %Ecto.Changeset{} = Assets.change_asset_tag(asset_tag)
    end
  end
end
