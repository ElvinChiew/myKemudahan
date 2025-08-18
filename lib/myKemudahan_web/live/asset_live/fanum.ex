defmodule MyKemudahanWeb.AssetLive.Fanum do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Assets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :asset_tag, Assets.list_asset_tags())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    asset = Assets.get_asset_tag!(id)
    {:ok, _} = Assets.delete_asset_tag(asset)

    {:noreply, stream_delete(socket, :assets, asset)}
  end

  @doc"""

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Asset")
    |> assign(:asset, Assets.get_asset!(id))
  end


  @impl true
  def handle_info({MyKemudahanWeb.AssetLive.FormComponent, {:saved, asset}}, socket) do
    {:noreply, stream_insert(socket, :assets, asset)}
  end


"""
end
