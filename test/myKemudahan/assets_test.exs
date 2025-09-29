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

  describe "bulk assets" do
    import MyKemudahan.AssetsFixtures

    test "create_bulk_asset/2 with valid data creates an asset and multiple asset tags" do
      category = category_fixture()

      asset_params = %{
        "name" => "Test Laptop",
        "description" => "Dell Laptop for testing",
        "cost_per_unit" => "1200.00",
        "status" => "available",
        "image" => "/uploads/test-image.jpg",
        "category_id" => category.id
      }

      bulk_params = %{
        "number_of_assets" => "3",
        "tag_prefix" => "LAPTOP",
        "initial_serial" => "1"
      }

      assert {:ok, %{asset: asset, asset_tags: asset_tags}} = Assets.create_bulk_asset(asset_params, bulk_params)

      # Verify asset was created
      assert asset.name == "Test Laptop"
      assert asset.description == "Dell Laptop for testing"
      assert asset.cost_per_unit == Decimal.new("1200.00")
      assert asset.status == "available"
      assert asset.category_id == category.id

      # Verify asset tags were created
      assert length(asset_tags) == 3

      # Verify tag names and serial numbers
      expected_tags = [
        %{tag: "LAPTOP", serial: "1"},
        %{tag: "LAPTOP", serial: "2"},
        %{tag: "LAPTOP", serial: "3"}
      ]

      for {expected, actual} <- Enum.zip(expected_tags, asset_tags) do
        assert actual.tag == expected.tag
        assert actual.serial == expected.serial
        assert actual.status == "available"
        assert actual.asset_id == asset.id
      end
    end

    test "create_bulk_asset/2 with invalid number of assets returns error" do
      category = category_fixture()

      asset_params = %{
        "name" => "Test Laptop",
        "description" => "Dell Laptop for testing",
        "cost_per_unit" => "1200.00",
        "status" => "available",
        "image" => "/uploads/test-image.jpg",
        "category_id" => category.id
      }

      bulk_params = %{
        "number_of_assets" => "0",
        "tag_prefix" => "LAPTOP",
        "initial_serial" => "1"
      }

      assert {:error, %Ecto.Changeset{}} = Assets.create_bulk_asset(asset_params, bulk_params)
    end

    test "create_bulk_asset/2 with too many assets returns error" do
      category = category_fixture()

      asset_params = %{
        "name" => "Test Laptop",
        "description" => "Dell Laptop for testing",
        "cost_per_unit" => "1200.00",
        "status" => "available",
        "image" => "/uploads/test-image.jpg",
        "category_id" => category.id
      }

      bulk_params = %{
        "number_of_assets" => "101",
        "tag_prefix" => "LAPTOP",
        "initial_serial" => "1"
      }

      assert {:error, %Ecto.Changeset{}} = Assets.create_bulk_asset(asset_params, bulk_params)
    end

    test "create_bulk_asset/2 preserves leading zeros in serial numbers" do
      category = category_fixture()

      asset_params = %{
        "name" => "Test Laptop",
        "description" => "Dell Laptop for testing",
        "cost_per_unit" => "1200.00",
        "status" => "available",
        "image" => "/uploads/test-image.jpg",
        "category_id" => category.id
      }

      bulk_params = %{
        "number_of_assets" => "3",
        "tag_prefix" => "LAPTOP",
        "initial_serial" => "001"  # Starting with leading zeros
      }

      assert {:ok, %{asset: asset, asset_tags: asset_tags}} = Assets.create_bulk_asset(asset_params, bulk_params)

      # Verify asset tags were created
      assert length(asset_tags) == 3

      # Verify tag names and serial numbers with leading zeros preserved
      expected_tags = [
        %{tag: "LAPTOP", serial: "001"},
        %{tag: "LAPTOP", serial: "002"},
        %{tag: "LAPTOP", serial: "003"}
      ]

      for {expected, actual} <- Enum.zip(expected_tags, asset_tags) do
        assert actual.tag == expected.tag
        assert actual.serial == expected.serial
        assert actual.status == "available"
        assert actual.asset_id == asset.id
      end
    end
  end

  describe "update_asset_tag_for_approval" do
    import MyKemudahan.AssetsFixtures

    test "returns error with asset name when not enough available tags" do
      # Create a category and asset
      category = category_fixture()
      asset = asset_fixture(%{category_id: category.id, name: "Test Laptop"})

      # Create only 2 asset tags (both available)
      asset_tag_fixture(%{asset_id: asset.id, status: "available"})
      asset_tag_fixture(%{asset_id: asset.id, status: "available"})

      # Try to approve for 5 items (more than available)
      result = Assets.update_asset_tag_for_approval(asset.id, 5)

      assert {:error, error_message} = result
      assert error_message =~ "Not enough available asset tags for 'Test Laptop'"
      assert error_message =~ "only 2 available, 5 requested"
    end

    test "returns error with 'Unknown Asset' when asset not found" do
      # Try to approve for non-existent asset
      result = Assets.update_asset_tag_for_approval(99999, 1)

      assert {:error, error_message} = result
      assert error_message =~ "Not enough available asset tags for 'Unknown Asset'"
    end

    test "successfully updates asset tags when enough are available" do
      # Create a category and asset
      category = category_fixture()
      asset = asset_fixture(%{category_id: category.id, name: "Test Laptop"})

      # Create 3 asset tags (all available)
      asset_tag_fixture(%{asset_id: asset.id, status: "available"})
      asset_tag_fixture(%{asset_id: asset.id, status: "available"})
      asset_tag_fixture(%{asset_id: asset.id, status: "available"})

      # Try to approve for 2 items (less than available)
      result = Assets.update_asset_tag_for_approval(asset.id, 2)

      assert {:ok, updated_tags} = result
      assert length(updated_tags) == 2

      # Verify all returned tags have status "loaned"
      for tag <- updated_tags do
        assert tag.status == "loaned"
        assert tag.borrow_count == 1
      end
    end
  end
end
