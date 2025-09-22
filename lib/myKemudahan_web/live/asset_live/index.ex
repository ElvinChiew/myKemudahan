defmodule MyKemudahanWeb.AssetLive.Index do
  use MyKemudahanWeb, :live_view

  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.Assets
  alias MyKemudahan.Assets.Asset

  import MyKemudahanWeb.AdminSidebar

  @impl true
  def mount(_params, _session, socket) do
    # Initialize with default values
    categories = Assets.list_categories_for_filter()

    {:ok,
     socket
     |> assign(:assets, [])
     |> assign(:total_count, 0)
     |> assign(:page, 1)
     |> assign(:per_page, 10)
     |> assign(:total_pages, 0)
     |> assign(:search, "")
     |> assign(:category_id, "")
     |> assign(:categories, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # Get current assigns or defaults
    current_search = socket.assigns[:search] || ""
    current_category_id = socket.assigns[:category_id] || ""
    current_per_page = socket.assigns[:per_page] || 10
    current_page = socket.assigns[:page] || 1

    # Merge with URL params
    merged_params = %{
      "page" => params["page"] || to_string(current_page),
      "per_page" => params["per_page"] || to_string(current_per_page),
      "search" => params["search"] || current_search,
      "category_id" => params["category_id"] || current_category_id
    }

    paginated_data = Assets.list_assets_paginated(merged_params)

    socket = socket
    |> assign(:assets, paginated_data.assets)
    |> assign(:total_count, paginated_data.total_count)
    |> assign(:page, paginated_data.page)
    |> assign(:per_page, paginated_data.per_page)
    |> assign(:total_pages, paginated_data.total_pages)
    |> assign(:search, merged_params["search"])
    |> assign(:category_id, merged_params["category_id"])
    |> stream(:assets, paginated_data.assets, reset: true)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Asset")
    |> assign(:asset, Assets.get_asset!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Asset")
    |> assign(:asset, %Asset{})
  end

  defp apply_action(socket, :bulk, _params) do
    socket
    |> assign(:page_title, "Add Bulk Asset")
    |> assign(:asset, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Assets")
    |> assign(:asset, nil)
  end

  @impl true
  def handle_info({MyKemudahanWeb.AssetLive.FormComponent, {:saved, asset}}, socket) do
    # Refresh the list after saving
    params = %{
      "page" => to_string(socket.assigns.page),
      "per_page" => to_string(socket.assigns.per_page),
      "search" => socket.assigns.search,
      "category_id" => socket.assigns.category_id
    }

    paginated_data = Assets.list_assets_paginated(params)

    {:noreply,
     socket
     |> assign(:assets, paginated_data.assets)
     |> assign(:total_count, paginated_data.total_count)
     |> assign(:total_pages, paginated_data.total_pages)
     |> stream(:assets, paginated_data.assets, reset: true)}
  end

  @impl true
  def handle_info({MyKemudahanWeb.AssetLive.BulkFormComponent, {:bulk_saved, :success}}, socket) do
    # Refresh the list after bulk saving
    params = %{
      "page" => to_string(socket.assigns.page),
      "per_page" => to_string(socket.assigns.per_page),
      "search" => socket.assigns.search,
      "category_id" => socket.assigns.category_id
    }

    paginated_data = Assets.list_assets_paginated(params)

    {:noreply,
     socket
     |> assign(:assets, paginated_data.assets)
     |> assign(:total_count, paginated_data.total_count)
     |> assign(:total_pages, paginated_data.total_pages)
     |> stream(:assets, paginated_data.assets, reset: true)}
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

    {:noreply, push_patch(socket, to: ~p"/assets?#{params}")}
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

    {:noreply, push_patch(socket, to: ~p"/assets?#{params}")}
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

    {:noreply, push_patch(socket, to: ~p"/assets?#{params}")}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    params = %{
      "page" => page,
      "per_page" => to_string(socket.assigns.per_page),
      "search" => socket.assigns.search,
      "category_id" => socket.assigns.category_id
    }

    {:noreply, push_patch(socket, to: ~p"/assets?#{params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    asset = Assets.get_asset!(id)
    {:ok, _} = Assets.delete_asset(asset)

    # Refresh the list after deletion
    params = %{
      "page" => to_string(socket.assigns.page),
      "per_page" => to_string(socket.assigns.per_page),
      "search" => socket.assigns.search,
      "category_id" => socket.assigns.category_id
    }

    paginated_data = Assets.list_assets_paginated(params)

    {:noreply,
     socket
     |> assign(:assets, paginated_data.assets)
     |> assign(:total_count, paginated_data.total_count)
     |> assign(:total_pages, paginated_data.total_pages)
     |> stream(:assets, paginated_data.assets, reset: true)}
  end
end
