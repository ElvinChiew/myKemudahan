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
      |> assign(:selected_request, nil)
      |> assign(:show_details, false)
      |> assign(:show_cancel_confirm, false)
      |> assign(:cancel_request_id, nil)

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

  def handle_event("view_details", %{"id" => request_id}, socket) do
    # Get the full request with preloaded items
    request = Requests.get_request!(request_id)

    {:noreply,
     socket
     |> assign(:selected_request, request)
     |> assign(:show_details, true)}
  end

  def handle_event("close_details", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_request, nil)
     |> assign(:show_details, false)}
  end

  def handle_event("confirm_cancel", %{"id" => request_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_cancel_confirm, true)
     |> assign(:cancel_request_id, request_id)}
  end

  def handle_event("hide_cancel_confirm", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_cancel_confirm, false)
     |> assign(:cancel_request_id, nil)}
  end

  def handle_event("execute_cancel", %{"id" => request_id}, socket) do
    IO.puts("=== EXECUTE CANCEL ===")
    IO.puts("Request ID: #{request_id}")

    case Requests.cancel_request(request_id) do
      {:ok, request} ->
        IO.puts("Request cancelled successfully: #{inspect(request)}")

        # Refresh the requests list after cancellation
        user = socket.assigns.current_user

        requests =
          case socket.assigns.status_filter do
            "all" -> Requests.list_user_requests(user.id)
            status -> Requests.list_user_requests_by_status(user.id, status)
          end

        IO.puts("Refreshed requests count: #{length(requests)}")

        {:noreply,
         socket
         |> assign(:requests, requests)
         |> assign(:show_cancel_confirm, false)
         |> assign(:cancel_request_id, nil)
         |> put_flash(:info, "Request cancelled successfully")}

      {:error, reason} ->
        IO.puts("Failed to cancel request: #{inspect(reason)}")
        {:noreply,
         socket
         |> assign(:show_cancel_confirm, false)
         |> assign(:cancel_request_id, nil)
         |> put_flash(:error, "Failed to cancel request: #{reason}")}
    end
  end

end
