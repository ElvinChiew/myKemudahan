defmodule MyKemudahanWeb.ReportLive.ReportView do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Reports
  alias MyKemudahan.Requests
  # alias MyKemudahan.Requests.RequestItem
  import MyKemudahanWeb.AdminSidebar

  @page_size 10

  def mount(_params, _session, socket) do
    reports = Reports.list_report()
    |> Enum.sort_by(& &1.reported_at, {:desc, NaiveDateTime})  # Sort by newest first

    total_count = length(reports)

    status_counts = %{
      "submitted" => Enum.count(reports, &(&1.status == "submitted")),
      "pending" => Enum.count(reports, &(&1.status == "pending")),
      "in_progress" => Enum.count(reports, &(&1.status == "in_progress")),
      "resolved" => Enum.count(reports, &(&1.status == "resolved"))
    }

    socket = assign(socket,
      reports: Enum.take(reports, @page_size),
      all_reports: reports,
      filtered_reports: reports,
      selected_status: "all",
      start_date: nil,
      end_date: nil,
      total_count: total_count,
      total_reports_count: total_count,  # Add this to track total count separately
      page_size: @page_size,
      current_page: 1,
      total_pages: ceil(total_count / @page_size),
      offset: 0,
      page_links: generate_page_links(1, ceil(total_count / @page_size)),
      selected_report: nil,
      show_details: false,
      request_items: [],
      status_counts: status_counts
    )

    {:ok, socket}
  end

  def handle_event("paginate", %{"page" => page_str}, socket) do
    page = String.to_integer(page_str)
    offset = (page - 1) * socket.assigns.page_size

    paginated_reports =
      socket.assigns.filtered_reports
      |> Enum.drop(offset)
      |> Enum.take(socket.assigns.page_size)

    page_links = generate_page_links(page, socket.assigns.total_pages)

    {:noreply,
     assign(socket,
       reports: paginated_reports,
       current_page: page,
       offset: offset,
       page_links: page_links
     )}
  end

  def handle_event("update_status", %{"id" => id, "status" => new_status}, socket) do
    report = Reports.get_report!(id)

    case Reports.update_report(report, %{status: new_status}) do
      {:ok, updated_report} ->
        updated_all =
          Enum.map(socket.assigns.all_reports, fn r ->
            if r.id == updated_report.id, do: updated_report, else: r
          end)

        filtered_reports =
          if socket.assigns.selected_status == "all" do
            updated_all
          else
            Enum.filter(updated_all, fn r -> r.status == socket.assigns.selected_status end)
          end

        offset = socket.assigns.offset
        current_reports =
          filtered_reports
          |> Enum.drop(offset)
          |> Enum.take(socket.assigns.page_size)

        total_count = length(filtered_reports)

        socket =
          socket
          |> assign(
            all_reports: updated_all,
            filtered_reports: filtered_reports,
            reports: current_reports,
            total_count: total_count
          )
          |> update_status_counts(updated_all)  # Update counts from all reports

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
    end
  end

  #Event handlers to open and close view modal
  def handle_event("view_details", %{"id" => id}, socket) do
    report = Reports.get_report!(id)
    request_items = get_request_items_for_report(report)

    {:noreply,
     socket
     |> assign(:selected_report, report)
     |> assign(:request_items, request_items)
     |> assign(:show_details, true)}
  end

  def handle_event("close_details", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_report, nil)
     |> assign(:show_details, false)}
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    filtered_reports =
      socket.assigns.all_reports
      |> filter_by_status(status)
      |> filter_by_date(parse_date(socket.assigns.start_date), parse_date(socket.assigns.end_date))

    total_count = length(filtered_reports)
    total_pages = max(ceil(total_count / socket.assigns.page_size), 1)

    socket =
      socket
      |> assign(
        selected_status: status,
        filtered_reports: filtered_reports,
        reports: Enum.take(filtered_reports, socket.assigns.page_size),
        total_count: total_count,  # This is filtered count
        current_page: 1,
        offset: 0,
        total_pages: total_pages,
        page_links: generate_page_links(1, total_pages)
      )
      # Don't update status counts here - keep showing total counts

    {:noreply, socket}
  end

  def handle_event("filter_date", %{"start_date" => start_date, "end_date" => end_date}, socket) do
    start_date = parse_date(start_date)
    end_date = parse_date(end_date)

    filtered_reports =
      socket.assigns.all_reports
      |> filter_by_status(socket.assigns.selected_status)
      |> filter_by_date(start_date, end_date)

    total_count = length(filtered_reports)
    total_pages = max(ceil(total_count / socket.assigns.page_size), 1)

    socket =
      socket
      |> assign(
        start_date: start_date && Date.to_iso8601(start_date),
        end_date: end_date && Date.to_iso8601(end_date),
        filtered_reports: filtered_reports,
        reports: Enum.take(filtered_reports, socket.assigns.page_size),
        total_count: total_count,  # This is filtered count
        current_page: 1,
        offset: 0,
        total_pages: total_pages,
        page_links: generate_page_links(1, total_pages)
      )
      # Don't update status counts here - keep showing total counts

    {:noreply, socket}
  end

  def handle_event("reset_filters", _params, socket) do
    filtered = filter_by_status(socket.assigns.all_reports, socket.assigns.selected_status)
    total_count = length(filtered)

    socket =
      socket
      |> assign(
        start_date: nil,
        end_date: nil,
        filtered_reports: filtered,
        reports: Enum.take(filtered, socket.assigns.page_size),
        total_count: total_count,  # This is filtered count
        current_page: 1,
        offset: 0,
        total_pages: max(ceil(total_count / socket.assigns.page_size), 1),
        page_links: generate_page_links(1, max(ceil(total_count / socket.assigns.page_size), 1))
      )
      # Don't update status counts here - keep showing total counts

    {:noreply, socket}
  end

    #Function fetching request items
    defp get_request_items_for_report(report) do
      # Assuming your report has a request_id field that links to the request
      if report.request_id do
        Requests.list_request_items_by_request_id(report.request_id)
      else
        []
      end
    end

  # Fix the unused variable warning by prefixing with underscore
  defp generate_page_links(_current_page, total_pages) when total_pages <= 5 do
    1..total_pages
  end

  defp generate_page_links(current_page, total_pages) do
    if current_page <= 3 do
      [1, 2, 3, 4, 5]
    else
      if current_page >= total_pages - 2 do
        [total_pages-4, total_pages-3, total_pages-2, total_pages-1, total_pages]
      else
        [current_page-2, current_page-1, current_page, current_page+1, current_page+2]
      end
    end
  end

  defp parse_date(""), do: nil
  defp parse_date(nil), do: nil
  defp parse_date(date_str), do: Date.from_iso8601!(date_str)

  defp filter_by_status(reports, "all"), do: reports
  defp filter_by_status(reports, status), do: Enum.filter(reports, &(&1.status == status))

  defp filter_by_date(reports, nil, nil), do: reports

  defp filter_by_date(reports, start_date, nil) do
    Enum.filter(reports, fn r ->
      NaiveDateTime.to_date(r.reported_at) >= start_date
    end)
  end

  defp filter_by_date(reports, nil, end_date) do
    Enum.filter(reports, fn r ->
      NaiveDateTime.to_date(r.reported_at) <= end_date
    end)
  end

  defp filter_by_date(reports, start_date, end_date) do
    IO.inspect({"Filtering dates", start_date: start_date, end_date: end_date})
    Enum.filter(reports, fn report ->
      date = NaiveDateTime.to_date(report.reported_at)
      date >= start_date and date <= end_date
    end)
  end

  defp update_status_counts(socket, _filtered_reports) do
    # Always count from the total reports, not filtered ones
    status_counts = %{
      "submitted" => Enum.count(socket.assigns.all_reports, &(&1.status == "submitted")),
      "pending" => Enum.count(socket.assigns.all_reports, &(&1.status == "pending")),
      "in_progress" => Enum.count(socket.assigns.all_reports, &(&1.status == "in_progress")),
      "resolved" => Enum.count(socket.assigns.all_reports, &(&1.status == "resolved"))
    }

    assign(socket, :status_counts, status_counts)
  end
end
