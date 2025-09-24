defmodule MyKemudahanWeb.UserLive.AdminViewUser do
  alias MyKemudahan.Requests
  alias MyKemudahan.Accounts

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  # Update mount to accept params
  def mount(%{"user_id" => user_id}, _session, socket) do
    # Update late fees for all overdue requests
    Requests.update_all_late_fees()

    # Get the target user (the one whose requests we're viewing)
    target_user = Accounts.get_user!(user_id)

    # Get requests for the target user, not the current user
    requests = Requests.list_user_requests(target_user.id)

    # Pagination settings
    per_page = 10
    total_pages = max(ceil(length(requests) / per_page), 1)
    paginated_requests = paginate_requests(requests, 1, per_page)

    socket =
      socket
      |> assign(:requests, paginated_requests)
      |> assign(:all_requests, requests)
      |> assign(:status_filter, "all")
      |> assign(:current_user, socket.assigns.current_user)
      |> assign(:target_user, target_user)  # Store the user we're viewing
      |> assign(:selected_request, nil)
      |> assign(:show_details, false)
      |> assign(:show_cancel_confirm, false)
      |> assign(:cancel_request_id, nil)
      |> assign(:page, 1)
      |> assign(:per_page, per_page)
      |> assign(:total_pages, total_pages)
      # Remove report-related assignments
      |> assign(:show_report_form, false)
      |> assign(:selected_report_item, nil)

    {:ok, socket}
  end

  # Update the filter_status handler to use target_user
  def handle_event("filter_status", %{"status" => status}, socket) do
    target_user = socket.assigns.target_user

    all_requests =
      case status do
        "all" -> Requests.list_user_requests(target_user.id)
        _ -> Requests.list_user_requests_by_status(target_user.id, status)
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

  # Add a back button handler
  def handle_event("go_back", _params, socket) do
    {:noreply, push_navigate(socket, to: "/users")}
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
     |> assign(:show_details, false)
     # Remove report-related assignments
     |> assign(:show_report_form, false)
     |> assign(:selected_report_item, nil)}
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
        target_user = socket.assigns.target_user

        all_requests =
          case socket.assigns.status_filter do
            "all" -> Requests.list_user_requests(target_user.id)
            status -> Requests.list_user_requests_by_status(target_user.id, status)
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
