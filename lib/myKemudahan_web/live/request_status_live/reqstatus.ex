defmodule MyKemudahanWeb.Reqstatus do
  alias MyKemudahan.Requests.Request
  alias MyKemudahan.Requests

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    requests = Requests.list_user_requests(user.id)

    # Pagination settings
    per_page = 10
    total_pages = max(ceil(length(requests) / per_page), 1)
    paginated_requests = paginate_requests(requests, 1, per_page)

    socket =
      socket
      |> assign(:requests, paginated_requests)
      |> assign(:all_requests, requests)  # Store all requests for filtering
      |> assign(:status_filter, "all")
      |> assign(:current_user, user)
      |> assign(:selected_request, nil)
      |> assign(:show_details, false)
      |> assign(:show_cancel_confirm, false)
      |> assign(:cancel_request_id, nil)
      |> assign(:page, 1)
      |> assign(:per_page, per_page)
      |> assign(:total_pages, total_pages)

    {:ok, socket}
  end

  # Handle Tabs Click
  def handle_event("filter_status", %{"status" => status}, socket) do
    user = socket.assigns.current_user

    all_requests =
      case status do
        "all" -> Requests.list_user_requests(user.id)
        _ -> Requests.list_user_requests_by_status(user.id, status)
      end

    # Update pagination
    total_pages = max(ceil(length(all_requests) / socket.assigns.per_page), 1)
    paginated_requests = paginate_requests(all_requests, 1, socket.assigns.per_page)

    {:noreply,
     assign(socket,
       requests: paginated_requests,
       all_requests: all_requests,
       status_filter: status,
       page: 1,
       total_pages: total_pages
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
    case Requests.cancel_request(request_id) do
      {:ok, _request} ->
        # Refresh the requests list after cancellation
        user = socket.assigns.current_user

        all_requests =
          case socket.assigns.status_filter do
            "all" -> Requests.list_user_requests(user.id)
            status -> Requests.list_user_requests_by_status(user.id, status)
          end

        # Recalculate pagination
        total_pages = max(ceil(length(all_requests) / socket.assigns.per_page), 1)
        paginated_requests = paginate_requests(all_requests, socket.assigns.page, socket.assigns.per_page)

        {:noreply,
         socket
         |> assign(:requests, paginated_requests)
         |> assign(:all_requests, all_requests)
         |> assign(:total_pages, total_pages)
         |> assign(:show_cancel_confirm, false)
         |> assign(:cancel_request_id, nil)
         |> put_flash(:info, "Request cancelled successfully")}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:show_cancel_confirm, false)
         |> assign(:cancel_request_id, nil)
         |> put_flash(:error, "Failed to cancel request: #{reason}")}
    end
  end

  # Pagination event handler
  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)
    paginated_requests = paginate_requests(socket.assigns.all_requests, page, socket.assigns.per_page)

    {:noreply,
     socket
     |> assign(:requests, paginated_requests)
     |> assign(:page, page)}
  end

  # Helper function for pagination
  defp paginate_requests(requests, page, per_page) do
    start_index = (page - 1) * per_page
    Enum.slice(requests, start_index, per_page)
  end
end
