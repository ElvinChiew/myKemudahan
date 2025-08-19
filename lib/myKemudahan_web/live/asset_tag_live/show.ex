defmodule MyKemudahanWeb.AssetTagLive.Show do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Assets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:asset_tag, Assets.get_asset_tag!(id))}
  end

  defp page_title(:show), do: "Show Asset tag"
  defp page_title(:edit), do: "Edit Asset tag"
end
