defmodule MyKemudahanWeb.RequestList do
  alias MyKemudahan.Requests
  alias MyKemudahan.Repo
  alias MyKemudahan.Mailer
  alias MyKemudahan.Mailer.RequestEmail

  import MyKemudahanWeb.AdminSidebar

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  @month_names ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  def mount(_params, _session, socket) do
    # Update late fees for all overdue requests
    Requests.update_all_late_fees()

    all_requests = Requests.list_all_requests()

    filtered_requests = apply_filters(all_requests, "all", nil, nil)

    status_counts = calculate_status_counts(all_requests)
    current_year = Date.utc_today().year
    available_years = for y <- (current_year-3)..current_year, do: y
    revenue_year = current_year
    monthly_revenue = calculate_monthly_revenue_for_year(all_requests, revenue_year)

    per_page = 10
    total_pages = max(ceil(length(filtered_requests) / per_page), 1)
    paginated_requests = paginate_requests(filtered_requests, 1, per_page)

    socket =
      socket
      |> assign(:requests, paginated_requests)
      |> assign(:status_filter, "all")
      |> assign(:status_counts, status_counts)
      |> assign(:revenue_year, revenue_year)
      |> assign(:available_years, available_years |> Enum.to_list())
      |> assign(:monthly_revenue, monthly_revenue)
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
      |> assign(:rejecting_request, nil)
      |> assign(:rejection_reason, "")
      |> assign(:show_reject_modal, false)

    {:ok, socket}
  end

  # Handle Tabs Click
  def handle_event("filter_status", %{"status" => status}, socket) do
    all_requests = Requests.list_all_requests()
    filtered_requests = apply_filters(all_requests, status, socket.assigns.from_date, socket.assigns.to_date)

    total_pages = max(ceil(length(filtered_requests) / socket.assigns.per_page), 1)
    paginated_requests = paginate_requests(filtered_requests, 1, socket.assigns.per_page)

    status_counts = calculate_status_counts(all_requests)
    monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

    {:noreply,
     assign(socket,
       requests: paginated_requests,
       all_requests: filtered_requests, # Store filtered requests for pagination
       status_filter: status,
       status_counts: status_counts,
       monthly_revenue: monthly_revenue,
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
              monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

              {:noreply,
               socket
               |> assign(:selected_request, updated_request)
               |> assign(:requests, paginated_requests)
               |> assign(:all_requests, all_requests)
               |> assign(:monthly_revenue, monthly_revenue)
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

  def handle_event("update_rejection_reason", %{"reason" => reason}, socket) do
    {:noreply, assign(socket, :rejection_reason, reason)}
  end

  # Handle opening the reject modal
  def handle_event("show_reject_modal", %{"id" => request_id}, socket) do
    {:noreply,
     socket
     |> assign(:rejecting_request, request_id)
     |> assign(:rejection_reason, "")
     |> assign(:show_reject_modal, true)}
  end

  def handle_event("update_rejection_reason", %{"reason" => reason}, socket) do
    {:noreply, assign(socket, :rejection_reason, reason)}
  end

  def handle_event("close_reject_modal", _, socket) do
    {:noreply,
     socket
     |> assign(:show_reject_modal, false)
     |> assign(:rejecting_request, nil)
     |> assign(:rejection_reason, "")}
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
        monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

        {:noreply,
         socket
         |> assign(:selected_request, updated_request)
         |> assign(:discount_amount, "")
         |> assign(:requests, filtered_requests)
         |> assign(:all_requests, all_requests)
         |> assign(:monthly_revenue, monthly_revenue)
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
      {:ok, request} ->

        # Log admin action for transparency
        try do
          MyKemudahan.SystemLogs.log_admin_action(
            socket.assigns.current_user.id,
            "approve_request",
            "Request",
            request.id,
            "Request approved by admin"
          )
        rescue
          error ->
            IO.inspect(error, label: "System logging failed")
        end

        #send email approval to user
        try do
          RequestEmail.approval_email(request)
          |> Mailer.deliver()
        rescue
          error ->
            IO.inspect(error, label: "Email delivery failed")
        end

        # Refresh the requests list
        all_requests = Requests.list_all_requests()
        filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)
        paginated_requests = paginate_requests(filtered_requests, socket.assigns.page, socket.assigns.per_page)

        # Update status counts
        status_counts = calculate_status_counts(all_requests)
        monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

        {:noreply,
         socket
         |> assign(:requests, paginated_requests)
         |> assign(:all_requests, filtered_requests)
         |> assign(:status_counts, status_counts)
         |> assign(:monthly_revenue, monthly_revenue)
         |> put_flash(:info, "Request approved successfully and email sent")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve request: #{reason}")}
    end
  end

  def handle_event("reject_request", %{}, socket) do
    case Requests.reject_request(socket.assigns.rejecting_request, socket.assigns.rejection_reason) do
      {:ok, request} ->

        # Log admin action for transparency
        try do
          MyKemudahan.SystemLogs.log_admin_action(
            socket.assigns.current_user.id,
            "reject_request",
            "Request",
            request.id,
            "Request rejected by admin. Reason: #{socket.assigns.rejection_reason}"
          )
        rescue
          error ->
            IO.inspect(error, label: "System logging failed")
        end

        complete_request = Requests.get_request_with_items!(request.id)

        try do
          RequestEmail.rejection_email(complete_request, socket.assigns.rejection_reason)
          |> Mailer.deliver()
        rescue
          error ->
            IO.inspect(error, label: "Email delivery failed")
            # Continue even if email fails
        end

        # Refresh the requests list
        all_requests = Requests.list_all_requests()
        filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, socket.assigns.from_date, socket.assigns.to_date)
        paginated_requests = paginate_requests(filtered_requests, socket.assigns.page, socket.assigns.per_page)

        # Update status counts
        status_counts = calculate_status_counts(all_requests)
        monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

        {:noreply,
         socket
         |> assign(:requests, paginated_requests)
         |> assign(:all_requests, filtered_requests)
         |> assign(:status_counts, status_counts)
         |> assign(:monthly_revenue, monthly_revenue)
         |> assign(:show_reject_modal, false)
         |> assign(:rejecting_request, nil)
         |> assign(:rejection_reason, "")
         |> put_flash(:info, "Request rejected successfully and email sent")}

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
      overdue: Enum.count(requests, &(&1.status == "overdue")),
      returned: Enum.count(requests, &(&1.status == "returned")),
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
        monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

        {:noreply,
        socket
        |> assign(:requests, paginated_requests)
        |> assign(:all_requests, filtered_requests)
        |> assign(:status_counts, status_counts)
        |> assign(:monthly_revenue, monthly_revenue)
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
  def handle_event("reset_filters", _, socket) do
    all_requests = Requests.list_all_requests()
    filtered_requests = apply_filters(all_requests, socket.assigns.status_filter, nil, nil)

    total_pages = max(ceil(length(filtered_requests) / socket.assigns.per_page), 1)
    paginated_requests = paginate_requests(filtered_requests, 1, socket.assigns.per_page)
    monthly_revenue = calculate_monthly_revenue_for_year(all_requests, socket.assigns.revenue_year)

    {:noreply,
     socket
     |> assign(:from_date, nil)
     |> assign(:to_date, nil)
     |> assign(:requests, paginated_requests)
     |> assign(:all_requests, filtered_requests)
     |> assign(:monthly_revenue, monthly_revenue)
     |> assign(:page, 1)
     |> assign(:total_pages, total_pages)}
  end

  def handle_event("set_revenue_year", %{"year" => year}, socket) do
    year_int =
      case Integer.parse(to_string(year)) do
        {num, _} -> num
        :error -> socket.assigns.revenue_year
      end

    current_year = Date.utc_today().year
    min_year = current_year - 3
    clamped_year =
      year_int
      |> max(min_year)
      |> min(current_year)

    all_requests = Requests.list_all_requests()
    monthly_revenue = calculate_monthly_revenue_for_year(all_requests, clamped_year)

    {:noreply,
     socket
     |> assign(:revenue_year, clamped_year)
     |> assign(:monthly_revenue, monthly_revenue)}
  end

  # Calculate 12-month revenue for approved and overdue requests based on borrow_from month
  defp calculate_monthly_revenue_for_year(requests, year) do
    month_keys = for m <- 1..12, do: {year, m}

    initial_totals =
      month_keys
      |> Enum.map(fn key -> {key, Decimal.new("0")} end)
      |> Map.new()

    totals =
      Enum.reduce(requests, initial_totals, fn request, acc ->
        cond do
          request.status not in ["approved", "overdue"] ->
            acc

          true ->
            borrow_from = request.borrow_from
            key = {borrow_from.year, borrow_from.month}

            if Map.has_key?(acc, key) do
              amount = final_amount(request)
              Map.update!(acc, key, fn current -> Decimal.add(current, amount) end)
            else
              acc
            end
        end
      end)

    amounts = Enum.map(month_keys, fn key -> Map.get(totals, key, Decimal.new("0")) end)
    max_amount = Enum.reduce(amounts, Decimal.new("0"), fn amt, acc -> if Decimal.compare(amt, acc) == :gt, do: amt, else: acc end)

    Enum.map(month_keys, fn {year, month} = key ->
      amount = Map.get(totals, key, Decimal.new("0"))
      percent =
        case Decimal.compare(max_amount, Decimal.new("0")) do
          :gt ->
            (Decimal.to_float(amount) / Decimal.to_float(max_amount)) * 100.0
          _ -> 0.0
        end

      %{
        label: month_label(year, month),
        amount: Decimal.to_string(amount),
        percentage: Float.round(percent, 2)
      }
    end)

  end

  defp final_amount(request) do
    cond do
      not is_nil(request.final_cost) -> request.final_cost
      not is_nil(request.total_cost) ->
        discount = request.discount_amount || Decimal.new("0")
        Decimal.sub(request.total_cost, discount)
      true -> Decimal.new("0")
    end
  end

  defp month_back(%Date{year: year, month: month} = _date, months_back) do
    total_months = (year * 12) + (month - 1) - months_back
    new_year = div(total_months, 12)
    new_month = rem(total_months, 12) + 1
    {:ok, d} = Date.new(new_year, new_month, 1)
    d
  end

  defp month_label(year, month) do
    name = Enum.at(@month_names, month - 1)
    name <> " " <> Integer.to_string(year)
  end
end
