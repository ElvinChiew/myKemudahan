defmodule MyKemudahanWeb.AssetTagLive.Index do
  use MyKemudahanWeb, :live_view

  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.Assets
  alias MyKemudahan.Assets.AssetTag
  import MyKemudahanWeb.AdminSidebar

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    cond do
      is_nil(user) or user.role != "admin" ->
        {:ok,
         socket
         |> Phoenix.LiveView.put_flash(:error, "You must be an admin to access this page.")
         |> Phoenix.LiveView.redirect(to: "/")}
      true ->
        {:ok, stream(socket, :asset_tags, Assets.list_asset_tags())}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
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
end
