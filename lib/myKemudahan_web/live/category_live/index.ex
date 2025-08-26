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
      |> assign(:category, nil)
      |> assign(:total_count, Assets.count_categories())
      |> stream(:categories, Assets.list_categories(1, @per_page))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    socket =
      socket
      |> assign(:page, page)
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

  defp paginate(socket) do
    total_count = Assets.count_categories()
    categories = Assets.list_categories(socket.assigns.page, socket.assigns.per_page)

    socket
    |> assign(:total_count, total_count)
    |> stream(:categories, categories, reset: true)
  end
end
