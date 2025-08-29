defmodule MyKemudahanWeb.CategoryLive.Index do
  use MyKemudahanWeb, :live_view

  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.Assets
  alias MyKemudahan.Assets.Category

  import MyKemudahanWeb.PaginationHelpers
  import MyKemudahanWeb.AdminSidebar

  @per_page 10

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:page, 1)
      |> assign(:per_page, @per_page)
      |> assign(:search, "")
      |> assign(:category, nil)
      |> assign(:total_count, Assets.count_categories())
      |> stream(:categories, Assets.list_categories(1, @per_page))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    search = Map.get(params, "search", "")  # Get search from params

    socket =
      socket
      |> assign(:page, page)
      |> assign(:search, search)  # Assign search term
      |> paginate()

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Assets.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({MyKemudahanWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Assets.get_category!(id)
    {:ok, _} = Assets.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, push_patch(socket, to: ~p"/categories?search=#{search}&page=1")}
  end

  def handle_event("clear_search", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/categories?page=1")}
  end

  defp paginate(socket) do
    search = socket.assigns.search
    total_count = if search != "", do: Assets.count_categories_search(search), else: Assets.count_categories()

    categories = if search != "" do
      Assets.search_categories(search, socket.assigns.page, socket.assigns.per_page)
    else
      Assets.list_categories(socket.assigns.page, socket.assigns.per_page)
    end

    socket
    |> assign(:total_count, total_count)
    |> stream(:categories, categories, reset: true)
  end
end
