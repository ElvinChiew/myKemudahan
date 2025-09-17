defmodule MyKemudahanWeb.Reqstatus do
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
      |> assign(:show_report_form, false)  # Add this
      |> assign(:selected_report_item, nil)  # Add this

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
     |> assign(:show_details, false)
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

  def handle_event("show_report_form", %{"item_id" => item_id}, socket) do
    # Find the item to report on from the currently selected request
    # The item_id here should be the request_item ID, not the asset ID
    item = find_item_by_id(socket.assigns.selected_request.request_items, item_id)

    {:noreply,
     socket
     |> assign(:show_report_form, true)
     |> assign(:selected_report_item, item)}
  end

  def handle_event("cancel_report", _, socket) do
    {:noreply,
     socket
     |> assign(:show_report_form, false)
     |> assign(:selected_report_item, nil)}
  end

  def handle_event("submit_report", %{"request_id" => request_id, "item_id" => item_id, "report_date" => date, "quantity" => quantity, "remarks" => remarks}, socket) do
    # Convert string values to appropriate types
    quantity = String.to_integer(quantity)
    request_id = String.to_integer(request_id)
    item_id = String.to_integer(item_id)

    # Parse the date string to NaiveDateTime with error handling
    case Date.from_iso8601(date) do
      {:ok, date} ->
        {:ok, reported_at} = NaiveDateTime.new(date, ~T[00:00:00])

        # Get the current user
        user = socket.assigns.current_user

        # We need to get the request again to ensure we have the request_items loaded
        request = MyKemudahan.Requests.get_request!(request_id)

        # Find the request item by its ID (not asset_id)
        item = Enum.find(request.request_items, &(&1.id == item_id))

        if item do
          # Prepare report attributes
          report_attrs = %{
            reporter_id: user.id,
            asset_id: item.asset_id,
            request_id: request_id,
            reported_at: reported_at,
            quantity: quantity,
            description: remarks,
            status: "submitted"
          }

          # Create the report directly using the Report changeset and Repo
          %MyKemudahan.Reports.Report{}
          |> MyKemudahan.Reports.Report.changeset(report_attrs)
          |> MyKemudahan.Repo.insert()
          |> case do
            {:ok, _report} ->
              {:noreply,
               socket
               |> assign(:show_report_form, false)
               |> assign(:selected_report_item, nil)
               |> put_flash(:info, "Report submitted successfully")}

            {:error, _changeset} ->
              {:noreply,
               socket
               |> put_flash(:error, "Failed to submit report. Please try again.")}
          end
        else
          IO.puts("Looking for item_id: #{item_id}")
          {:noreply,
           socket
           |> put_flash(:error, "Item not found. Please try again.")}
        end

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid date format. Please use YYYY-MM-DD format.")}
    end
  end

  def handle_event("submit_return_request", %{"id" => request_id}, socket) do
    case Requests.submit_return_request(request_id) do
      {:ok, _return_request} ->
        # Refresh the requests list
        user = socket.assigns.current_user
        all_requests = Requests.list_user_requests(user.id)

        paginated_requests = paginate_requests(all_requests, socket.assigns.page, socket.assigns.per_page)

        {:noreply,
         socket
         |> assign(:requests, paginated_requests)
         |> assign(:all_requests, all_requests)
         |> put_flash(:info, "Return request submitted successfully. Waiting for admin approval.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to submit return request: #{reason}")}
    end
  end

  # Helper function to find an item by ID
  defp find_item_by_id(items, item_id) when is_binary(item_id) do
    item_id = String.to_integer(item_id)
    Enum.find(items, &(&1.id == item_id))
  end

  defp find_item_by_id(_, _), do: nil
end
