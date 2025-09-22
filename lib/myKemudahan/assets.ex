defmodule MyKemudahan.Assets do
  @moduledoc """
  The Assets context.
  """

  import Ecto.Query, warn: false
  alias MyKemudahan.Assets.Asset
  alias MyKemudahan.Assets.AssetTag
  alias MyKemudahan.Repo

  alias MyKemudahan.Assets.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories(page \\ 1, per_page \\ 10) do
    Category
    |> limit(^per_page)
    |> offset(^((page-1) * per_page))
    |> Repo.all()
  end

  def list_all_categories do
    Repo.all(Category)
  end

  #def list_categories do
  #  Repo.all(Category)
  #end

  def count_categories do
    Repo.aggregate(Category, :count, :id)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @doc """
  Returns the list of assets.

  ## Examples

      iex> list_assets()
      [%Asset{}, ...]

  """
  def list_assets do
    Repo.all(Asset) |> Repo.preload(:category)
  end

  def list_asset_tags do
    Repo.all(AssetTag) |> Repo.preload(asset: [:category])
  end

  @doc """
  Gets a single asset.

  Raises `Ecto.NoResultsError` if the Asset does not exist.

  ## Examples

      iex> get_asset!(123)
      %Asset{}

      iex> get_asset!(456)
      ** (Ecto.NoResultsError)

  """
  #def get_asset!(id), do: Repo.get!(Asset, id)
  def get_asset!(id), do:
    Repo.get!(Asset, id)
    |> Repo.preload(:asset_tags)

  def get_asset_tag!(id), do:
    Repo.get!(AssetTag, id)
    |> Repo.preload(:asset)

  @doc """
  Creates a asset.

  ## Examples

      iex> create_asset(%{field: value})
      {:ok, %Asset{}}

      iex> create_asset(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_asset(attrs \\ %{}) do
    %Asset{}
    |> Asset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a asset.

  ## Examples

      iex> update_asset(asset, %{field: new_value})
      {:ok, %Asset{}}

      iex> update_asset(asset, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_asset(%Asset{} = asset, attrs) do
    asset
    |> Asset.changeset(attrs)
    |> Repo.update()
  end

  def create_asset_tag(attrs \\ %{}) do
    %AssetTag{}
    |> AssetTag.changeset(attrs)
    |> Repo.insert()
  end

  def update_asset_tag(%AssetTag{} = asset_tag, attrs) do
    asset_tag
    |> AssetTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a asset.

  ## Examples

      iex> delete_asset(asset)
      {:ok, %Asset{}}

      iex> delete_asset(asset)
      {:error, %Ecto.Changeset{}}

  """
  def delete_asset(%Asset{} = asset) do
    Repo.delete(asset)
  end

  def delete_asset_tag(%AssetTag{} = asset_tag) do
    Repo.delete(asset_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking asset changes.

  ## Examples

      iex> change_asset(asset)
      %Ecto.Changeset{data: %Asset{}}

  """
  def change_asset(%Asset{} = asset, attrs \\ %{}) do
    Asset.changeset(asset, attrs)
  end

  def list_tags_paginated(page, per_page) do
    offset = (page - 1) * per_page

    AssetTag
    |> limit(^per_page)
    |> offset(^offset)
    |> preload(asset: [:category])
    |> Repo.all()
  end

  def count_tags do
    Repo.aggregate(AssetTag, :count, :id)
  end

  def change_asset_tag(%AssetTag{} = asset_tag, attrs \\ %{}) do
    AssetTag.changeset(asset_tag, attrs)
  end

  # Count available tags for a given asset (status == "available")
  def count_available_tags(asset_id) when is_integer(asset_id) do
    from(at in AssetTag,
      where: at.asset_id == ^asset_id and at.status == ^"available"
    )
    |> Repo.aggregate(:count, :id)
  end

  def list_asset_tags_paginated(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    search = params["search"]
    category_id = params["category_id"]
    status = params["status"]

    offset = (page - 1) * per_page

    # Base query with joins and preloads
    base_query = from at in AssetTag,
                join: a in assoc(at, :asset),
                join: c in assoc(a, :category),
                preload: [asset: {a, category: c}]

    # Apply search filter if provided
    query = if search && search != "" do
      from [at, a, c] in base_query,
      where: ilike(a.name, ^"%#{search}%")
    else
      base_query
    end

    # Apply category filter if provided
    query = if category_id && category_id != "" do
      from [at, a, c] in query,
      where: a.category_id == ^category_id
    else
      query
    end

    # Apply status filter if provided
    query = if status && status != "" do
      from [at, a, c] in query,
      where: at.status == ^status
    else
      query
    end

    # Get paginated results
    asset_tags = query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    # Get total count for pagination
    total_count = query
      |> exclude(:preload)
      |> exclude(:limit)
      |> exclude(:offset)
      |> Repo.aggregate(:count, :id)

    %{
      asset_tags: asset_tags,
      total_count: total_count,
      page: page,
      per_page: per_page,
      total_pages: ceil(total_count / per_page)
    }
  end

  def list_assets_paginated(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    search = params["search"]
    category_id = params["category_id"]

    offset = (page - 1) * per_page

    # Base query with aggregates for tag counts
    base_query = from a in Asset,
                join: c in assoc(a, :category),
                left_join: at in assoc(a, :asset_tags),
                group_by: [a.id, c.id],
                preload: [category: c],
                select: %{
                  a |
                  total_tags_count: count(at.id),
                  available_tags_count:
                    fragment(
                      "COALESCE(SUM(CASE WHEN ? = ? THEN 1 ELSE 0 END), 0)",
                      at.status,
                      ^"available"
                    )
                }

    # Apply search filter if provided
    query = if search && search != "" do
      from [a, c, at] in base_query,
      where: ilike(a.name, ^"%#{search}%")
    else
      base_query
    end

    # Apply category filter if provided
    query = if category_id && category_id != "" do
      from [a, c, at] in query,
      where: a.category_id == ^category_id
    else
      query
    end

    # Get paginated results
    assets = query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    # Build a separate count query without group_by to avoid aggregation error
    count_base = from a in Asset,
                   join: c in assoc(a, :category)

    count_query = if search && search != "" do
      from [a, c] in count_base,
        where: ilike(a.name, ^"%#{search}%")
    else
      count_base
    end

    count_query = if category_id && category_id != "" do
      from [a, c] in count_query,
        where: a.category_id == ^category_id
    else
      count_query
    end

    total_count = count_query
      |> distinct(true)
      |> Repo.aggregate(:count, :id)

    %{
      assets: assets,
      total_count: total_count,
      page: page,
      per_page: per_page,
      total_pages: ceil(total_count / per_page)
    }
  end

  # Add a function to get all categories for the filter dropdown
  def list_categories_for_filter do
    from(c in Category, order_by: c.name)
    |> Repo.all()
  end

  def search_categories(search_term, page \\ 1, per_page \\ 10) do
    offset = (page - 1) * per_page

    Category
    |> where([c], ilike(c.name, ^"%#{search_term}%"))
    |> order_by(asc: :name)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  def count_categories_search(search_term) do
    Category
    |> where([c], ilike(c.name, ^"%#{search_term}%"))
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Creates a bulk asset with multiple asset tags.

  ## Examples

      iex> create_bulk_asset(%{name: "Laptop", description: "Dell Laptop"}, %{number_of_assets: 5, tag_prefix: "LAPTOP", initial_serial: 1})
      {:ok, %{asset: %Asset{}, asset_tags: [%AssetTag{}, ...]}}

      iex> create_bulk_asset(%{name: "Laptop"}, %{number_of_assets: 0})
      {:error, %Ecto.Changeset{}}

  """
  def create_bulk_asset(asset_params, bulk_params) do
    number_of_assets = String.to_integer(bulk_params["number_of_assets"] || "0")
    tag_prefix = bulk_params["tag_prefix"] || ""
    initial_serial_str = bulk_params["initial_serial"] || "1"
    initial_serial = String.to_integer(initial_serial_str)

    # Validate bulk parameters
    if number_of_assets <= 0 or number_of_assets > 100 do
      {:error, %Ecto.Changeset{errors: [number_of_assets: {"must be between 1 and 100", []}], valid?: false}}
    else
      # Use a transaction to ensure all-or-nothing creation
      Repo.transaction(fn ->
        # Create the asset first
        asset_changeset = Asset.changeset(%Asset{}, asset_params)

        case Repo.insert(asset_changeset) do
          {:ok, asset} ->
            # Generate asset tags
            asset_tags = generate_asset_tags(asset.id, number_of_assets, tag_prefix, initial_serial, initial_serial_str, asset_params["status"] || "available")

            # Insert all asset tags
            case Repo.insert_all(AssetTag, asset_tags) do
              {count, _} when count == number_of_assets ->
                # Reload the asset with its tags
                asset_with_tags = Repo.get!(Asset, asset.id) |> Repo.preload(:asset_tags)
                %{asset: asset_with_tags, asset_tags: asset_with_tags.asset_tags}

              {count, _} ->
                Repo.rollback("Failed to create all asset tags. Expected #{number_of_assets}, created #{count}")
            end

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    end
  end

  defp generate_asset_tags(asset_id, number_of_assets, tag_prefix, initial_serial, initial_serial_str, status) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    for i <- 0..(number_of_assets - 1) do
      # Calculate the serial number preserving leading zeros
      current_serial = initial_serial + i

      # If the original input had leading zeros, preserve them
      serial_display = if String.starts_with?(initial_serial_str, "0") do
        # Preserve the original format with leading zeros
        original_length = String.length(initial_serial_str)
        String.pad_leading(to_string(current_serial), original_length, "0")
      else
        to_string(current_serial)
      end

      # Use just the tag prefix (no serial number in tag)
      tag = tag_prefix

      %{
        asset_id: asset_id,
        tag: tag,
        serial: serial_display,
        status: status,
        inserted_at: now,
        updated_at: now
      }
    end
  end
end
