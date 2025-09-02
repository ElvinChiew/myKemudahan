defmodule MyKemudahanWeb.AssetTagLive.Index do
  use MyKemudahanWeb, :live_view

  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.Assets
  alias MyKemudahan.Assets.AssetTag
  import MyKemudahanWeb.AdminSidebar

  @impl true
  def mount(_params, _session, socket) do
    # Initialize with default params
    params = %{
      "page" => "1",
      "per_page" => "10",
      "search" => "",
      "category_id" => ""
    }

    paginated_data = Assets.list_asset_tags_paginated(params)
    categories = Assets.list_categories_for_filter()

    {:ok,
     socket
     |> assign(:asset_tags, paginated_data.asset_tags)
     |> assign(:total_count, paginated_data.total_count)
     |> assign(:page, paginated_data.page)
     |> assign(:per_page, paginated_data.per_page)
     |> assign(:total_pages, paginated_data.total_pages)
     |> assign(:search, "")
     |> assign(:category_id, "")
     |> assign(:categories, categories)
     |> stream(:asset_tags, paginated_data.asset_tags)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # Merge URL params with current assigns
    current_params = %{
      "page" => to_string(socket.assigns.page || 1),
      "per_page" => to_string(socket.assigns.per_page || 10),
      "search" => socket.assigns.search || "",
      "category_id" => socket.assigns.category_id || ""
    }

    merged_params = Map.merge(current_params, Map.new(params))

    paginated_data = Assets.list_asset_tags_paginated(merged_params)

    socket = socket
    |> assign(:asset_tags, paginated_data.asset_tags)
    |> assign(:total_count, paginated_data.total_count)
    |> assign(:page, paginated_data.page)
    |> assign(:per_page, paginated_data.per_page)
    |> assign(:total_pages, paginated_data.total_pages)
    |> assign(:search, merged_params["search"])
    |> assign(:category_id, merged_params["category_id"])
    |> stream(:asset_tags, paginated_data.asset_tags, reset: true)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Asset tag")
    |> assign(:asset_tag, Assets.get_asset_tag!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Asset tag")
    |> assign(:asset_tag, %AssetTag{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Asset tags")
    |> assign(:asset_tag, nil)
  end

  @impl true
  def handle_info({MyKemudahanWeb.AssetTagLive.FormComponent, {:saved, asset_tag}}, socket) do
    {:noreply, stream_insert(socket, :asset_tags, asset_tag)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    asset_tag = Assets.get_asset_tag!(id)
    {:ok, _} = Assets.delete_asset_tag(asset_tag)

    {:noreply, stream_delete(socket, :asset_tags, asset_tag)}
  end
  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    # Reset to page 1 when searching
    params = %{
      "page" => "1",
      "per_page" => to_string(socket.assigns.per_page),
      "search" => search,
      "category_id" => socket.assigns.category_id
    }

    {:noreply, push_patch(socket, to: ~p"/asset_tags?#{params}")}
  end

  @impl true
  def handle_event("filter", %{"category_id" => category_id}, socket) do
    # Reset to page 1 when filtering
    params = %{
      "page" => "1",
      "per_page" => to_string(socket.assigns.per_page),
      "search" => socket.assigns.search,
      "category_id" => category_id
    }

    {:noreply, push_patch(socket, to: ~p"/asset_tags?#{params}")}
  end

  @impl true
  def handle_event("clear_filters", _, socket) do
    # Clear all filters and reset to page 1
    params = %{
      "page" => "1",
      "per_page" => to_string(socket.assigns.per_page),
      "search" => "",
      "category_id" => ""
    }

    {:noreply, push_patch(socket, to: ~p"/asset_tags?#{params}")}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    params = %{
      "page" => page,
      "per_page" => to_string(socket.assigns.per_page),
      "search" => socket.assigns.search,
      "category_id" => socket.assigns.category_id
    }

    {:noreply, push_patch(socket, to: ~p"/asset_tags?#{params}")}
  end
end
