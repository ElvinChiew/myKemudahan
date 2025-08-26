defmodule MyKemudahanWeb.RequestList do
  alias MyKemudahan.Requests
  alias MyKemudahan.Repo

  import MyKemudahanWeb.AdminSidebar

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    all_requests = Requests.list_all_requests()

    filtered_requests = apply_filters(all_requests, "all", nil, nil)

    status_counts = calculate_status_counts(all_requests)

    per_page = 10
    total_pages = max(ceil(length(filtered_requests) / per_page), 1)
    paginated_requests = paginate_requests(filtered_requests, 1, per_page)

    socket =
      socket
      |> assign(:requests, paginated_requests)
      |> assign(:status_filter, "all")
      |> assign(:status_counts, status_counts)
      |> assign(:page_title, "Admin - All Requests")
      |> assign(:all_requests, filtered_requests)
      |> assign(:selected_request, nil)
      |> assign(:show_details, false)
      |> assign(:discount_amount, "")
      |> assign(:page, 1)
      |> assign(:per_page, per_page)
      |> assign(:total_pages, total_pages)
      |> assign(:from_date, nil)
      |> assign(:to_date, nil)

    {:ok, socket}
  end

  # Handle Tabs Click
  def handle_event("filter_status", %{"status" => status}, socket) do
    all_requests = Requests.list_all_requests()
    filtered_requests = apply_filters(all_requests, status, socket.assigns.from_date, socket.assigns.to_date)

    total_pages = max(ceil(length(filtered_requests) / socket.assigns.per_page), 1)
    paginated_requests = paginate_requests(filtered_requests, 1, socket.assigns.per_page)

    status_counts = calculate_status_counts(all_requests)

    {:noreply,
     assign(socket,
       requests: paginated_requests,
       all_requests: filtered_requests, # Store filtered requests for pagination
       status_filter: status,
       status_counts: status_counts,
       page: 1,
       total_pages: total_pages
     )}
  end

  def handle_event("filter_by_date", %{"from_date" => from_date, "to_date" => to_date}, socket) do
    all_requests = Requests.list_all_requests()

    filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, from_date, to_date)

    paginated_requests = paginate_requests(filtered_requests, 1, socket.assigns.per_page)
    total_pages = max(ceil(length(filtered_requests) / socket.assigns.per_page), 1)

    {:noreply,
     socket
     |> assign(:from_date, from_date)
     |> assign(:to_date, to_date)
     |> assign(:requests, paginated_requests)
     |> assign(:all_requests, filtered_requests)
     |> assign(:page, 1)
     |> assign(:total_pages, total_pages)}
  end


  def handle_event("view_details", %{"id" => request_id}, socket) do
    request = Requests.get_request!(request_id)
    {:noreply,
     socket
     |> assign(:selected_request, request)
     |> assign(:discount_amount, request.discount_amount || "")
     |> assign(:show_details, true)}
  end

  def handle_event("update_discount", %{"discount_amount" => discount_amount}, socket) do
    {:noreply, assign(socket, :discount_amount, discount_amount)}
  end

  def handle_event("apply_discount", %{"discount_amount" => discount_amount}, socket) do
    case parse_discount_amount(discount_amount) do
      {:ok, decimal} ->
        if Decimal.compare(decimal, Decimal.new("0")) == :gt do
          case Requests.apply_discount(socket.assigns.selected_request.id, decimal) do
            {:ok, updated_request} ->
              # Refresh the requests list
              all_requests = Requests.list_all_requests()
              filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)
              paginated_requests = paginate_requests(filtered_requests, socket.assigns.page, socket.assigns.per_page)

              {:noreply,
               socket
               |> assign(:selected_request, updated_request)
               |> assign(:requests, paginated_requests)
               |> assign(:all_requests, all_requests)
               |> put_flash(:info, "Discount applied successfully")}

            {:error, _changeset} ->
              {:noreply,
               socket
               |> put_flash(:error, "Failed to apply discount")}
          end
        else
          {:noreply,
           socket
           |> put_flash(:error, "Please enter a valid discount amount greater than 0")}
        end

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "Please enter a valid number")}
    end
  end

  # Helper function to parse discount amount
  defp parse_discount_amount(nil), do: :error
  defp parse_discount_amount(""), do: :error
  defp parse_discount_amount(amount) when is_binary(amount) do
    case Decimal.parse(amount) do
      {decimal, ""} -> {:ok, decimal}
      _ -> :error
    end
  end
  defp parse_discount_amount(_), do: :error

  def handle_event("remove_discount", _, socket) do
    case Requests.remove_discount(socket.assigns.selected_request.id) do
      {:ok, updated_request} ->
        # Refresh the requests list
        all_requests = Requests.list_all_requests()
        filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)

        {:noreply,
         socket
         |> assign(:selected_request, updated_request)
         |> assign(:discount_amount, "")
         |> assign(:requests, filtered_requests)
         |> assign(:all_requests, all_requests)
         |> put_flash(:info, "Discount removed successfully")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to remove discount")}
    end
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)
    filtered_requests = socket.assigns.all_requests
    total_pages = max(ceil(length(filtered_requests) / socket.assigns.per_page), 1)
    paginated_requests = paginate_requests(filtered_requests, page, socket.assigns.per_page)

    {:noreply,
     socket
     |> assign(:requests, paginated_requests)
     |> assign(:page, page)
     |> assign(:total_pages, total_pages)}
  end

  defp apply_status_filter(requests, "all"), do: requests
  defp apply_status_filter(requests, status), do: Enum.filter(requests, &(&1.status == status))

  def handle_event("close_details", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_request, nil)
     |> assign(:show_details, false)}
  end

  defp percentage(part, whole) when whole > 0 do
    round((part / whole) * 100)
  end

  defp percentage(_part, _whole), do: 0

  defp discount_percentage(request) do
    total_cost = request.total_cost
    discount_amount = request.discount_amount

    if total_cost && discount_amount do
      case Decimal.compare(total_cost, Decimal.new("0")) do
        :gt ->
          total_float = Decimal.to_float(total_cost)
          discount_float = Decimal.to_float(discount_amount)
          (discount_float / total_float) * 100
        _ ->
          0
      end
    else
      0
    end
  end

  defp paginate_requests(requests, page, per_page) do
    start_index = (page - 1) * per_page
    Enum.slice(requests, start_index, per_page)
  end

  def handle_event("approve_request", %{"id" => request_id}, socket) do
    case Requests.approve_request(request_id) do
      {:ok, _request} ->
        # Refresh the requests list
        all_requests = Requests.list_all_requests()
        filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)
        paginated_requests = paginate_requests(filtered_requests, socket.assigns.page, socket.assigns.per_page)

        # Update status counts
        status_counts = calculate_status_counts(all_requests)

        {:noreply,
         socket
         |> assign(:requests, paginated_requests)
         |> assign(:all_requests, filtered_requests)
         |> assign(:status_counts, status_counts)
         |> put_flash(:info, "Request approved successfully")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve request: #{reason}")}
    end
  end

  def handle_event("reject_request", %{"id" => request_id}, socket) do
    case Requests.reject_request(request_id) do
      {:ok, _request} ->
        # Refresh the requests list
        all_requests = Requests.list_all_requests()
        filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)
        paginated_requests = paginate_requests(filtered_requests, socket.assigns.page, socket.assigns.per_page)

        # Update status counts
        status_counts = calculate_status_counts(all_requests)

        {:noreply,
         socket
         |> assign(:requests, paginated_requests)
         |> assign(:all_requests, filtered_requests)
         |> assign(:status_counts, status_counts)
         |> put_flash(:info, "Request rejected successfully")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject request: #{reason}")}
    end
  end

  # Add this helper function to calculate status counts
  defp calculate_status_counts(requests) do
    %{
      total: length(requests),
      sent: Enum.count(requests, &(&1.status == "sent")),
      pending: Enum.count(requests, &(&1.status == "pending")),
      approved: Enum.count(requests, &(&1.status == "approved")),
      rejected: Enum.count(requests, &(&1.status == "rejected")),
      cancelled: Enum.count(requests, &(&1.status == "cancelled"))
    }
  end

  # Add this function to handle setting status to pending
  def handle_event("pending_request", %{"id" => request_id}, socket) do
    case set_request_status(request_id, "pending") do
      {:ok, _request} ->
        # Refresh the requests list
        all_requests = Requests.list_all_requests()
        filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)
        paginated_requests = paginate_requests(filtered_requests, socket.assigns.page, socket.assigns.per_page)

        # Update status counts
        status_counts = calculate_status_counts(all_requests)

        {:noreply,
        socket
        |> assign(:requests, paginated_requests)
        |> assign(:all_requests, filtered_requests)
        |> assign(:status_counts, status_counts)
        |> put_flash(:info, "Request marked as pending")}

      {:error, reason} ->
        {:noreply,
        socket
        |> put_flash(:error, "Failed to update request: #{reason}")}
    end
  end

  # Helper function to set request status
  defp set_request_status(request_id, status) do
    case Requests.get_request!(request_id) do
      nil -> {:error, "Request not found"}
      request ->
        request
        |> Ecto.Changeset.change(%{status: status})
        |> Repo.update()
    end
  end

  defp apply_filters(requests, status_filter, from_date, to_date) do
    requests
    |> filter_by_date(from_date, to_date)
    |> apply_status_filter(status_filter)
  end

  defp filter_by_date(requests, nil, nil), do: requests
  defp filter_by_date(requests, from_date, to_date) do
    Enum.filter(requests, fn request ->
      with {:ok, filter_from} when not is_nil(from_date) <- Date.from_iso8601(from_date),
           {:ok, filter_to} when not is_nil(to_date) <- Date.from_iso8601(to_date) do

        borrow_from = request.borrow_from
        borrow_to = request.borrow_to


        Date.compare(borrow_from, filter_to) != :gt and Date.compare(borrow_to, filter_from) != :lt
      else
        _ -> true
      end
    end)
  end
end
