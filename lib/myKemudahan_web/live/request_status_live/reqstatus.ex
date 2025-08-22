defmodule MyKemudahanWeb.Reqstatus do

  alias MyKemudahan.Requests.Request
  alias MyKemudahan.Requests

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    requests = Requests.list_user_requests(user.id)

    #{:ok, assign(socket, requests: requests)}
    socket =
      socket
      |> assign(:requests, requests)
      |> assign(:status_filter, "all")
      |> assign(:current_user, user)

    {:ok, socket}
  end

  #Handle Tabs Click
  def handle_event("filter_status", %{"status" => status}, socket) do
    user = socket.assigns.current_user

    requests =
      case status do
        "all" -> Requests.list_user_requests(user.id)
        _ -> Requests.list_user_requests_by_status(user.id, status)
      end
      {:noreply,
        assign(socket,
          requests: requests,
          status_filter: status
          )}
  end

  def handle_event("request_asset", _params, socket) do
    {:noreply, push_navigate(socket, to: "/requser")}
  end

  def handle_event("go_to_menu", _params, socket) do
    {:noreply, push_navigate(socket, to: "/usermenu")}
  end
end
