defmodule MyKemudahanWeb.SystemLogsLive do
  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.SystemLogs
  import MyKemudahanWeb.AdminSidebar

  @page_size 20

  def mount(_params, _session, socket) do
    system_logs = SystemLogs.list_system_logs()
    total_count = length(system_logs)

    socket = assign(socket,
      system_logs: Enum.take(system_logs, @page_size),
      all_system_logs: system_logs,
      filtered_system_logs: system_logs,
      total_count: total_count,
      page_size: @page_size,
      current_page: 1,
      total_pages: ceil(total_count / @page_size),
      offset: 0,
      page_links: generate_page_links(1, ceil(total_count / @page_size)),
      action_filter: "all",
      date_filter: "all",
      from_date: nil,
      to_date: nil
    )

    {:ok, socket}
  end

  def handle_event("paginate", %{"page" => page_str}, socket) do
    page = String.to_integer(page_str)
    offset = (page - 1) * socket.assigns.page_size

    paginated_logs =
      socket.assigns.filtered_system_logs
      |> Enum.drop(offset)
      |> Enum.take(socket.assigns.page_size)

    page_links = generate_page_links(page, socket.assigns.total_pages)

    {:noreply,
     assign(socket,
       system_logs: paginated_logs,
       current_page: page,
       offset: offset,
       page_links: page_links
     )}
  end

  def handle_event("filter_by_action", %{"action" => action}, socket) do
    filtered_logs = if action == "all" do
      socket.assigns.all_system_logs
    else
      Enum.filter(socket.assigns.all_system_logs, &(&1.action == action))
    end

    paginated_logs = Enum.take(filtered_logs, socket.assigns.page_size)
    total_count = length(filtered_logs)
    total_pages = ceil(total_count / socket.assigns.page_size)

    {:noreply,
     assign(socket,
       system_logs: paginated_logs,
       filtered_system_logs: filtered_logs,
       total_count: total_count,
       total_pages: total_pages,
       current_page: 1,
       offset: 0,
       action_filter: action,
       page_links: generate_page_links(1, total_pages)
     )}
  end

  def handle_event("filter_by_date", %{"date" => date}, socket) do
    filtered_logs = if date == "all" do
      socket.assigns.all_system_logs
    else
      today = Date.utc_today()
      case date do
        "today" ->
          Enum.filter(socket.assigns.all_system_logs, fn log ->
            log_date = NaiveDateTime.to_date(log.performed_at)
            Date.compare(log_date, today) == :eq
          end)
        "week" ->
          week_ago = Date.add(today, -7)
          Enum.filter(socket.assigns.all_system_logs, fn log ->
            log_date = NaiveDateTime.to_date(log.performed_at)
            Date.compare(log_date, week_ago) != :lt
          end)
        "month" ->
          month_ago = Date.add(today, -30)
          Enum.filter(socket.assigns.all_system_logs, fn log ->
            log_date = NaiveDateTime.to_date(log.performed_at)
            Date.compare(log_date, month_ago) != :lt
          end)
        _ ->
          socket.assigns.all_system_logs
      end
    end

    paginated_logs = Enum.take(filtered_logs, socket.assigns.page_size)
    total_count = length(filtered_logs)
    total_pages = ceil(total_count / socket.assigns.page_size)

    {:noreply,
     assign(socket,
       system_logs: paginated_logs,
       filtered_system_logs: filtered_logs,
       total_count: total_count,
       total_pages: total_pages,
       current_page: 1,
       offset: 0,
       date_filter: date,
       page_links: generate_page_links(1, total_pages)
     )}
  end

  def handle_event("filter_by_date_range", %{"from_date" => from_date, "to_date" => to_date}, socket) do
    filtered_logs = if from_date != "" and to_date != "" do
      from_date_parsed = Date.from_iso8601!(from_date)
      to_date_parsed = Date.from_iso8601!(to_date)

      Enum.filter(socket.assigns.all_system_logs, fn log ->
        log_date = NaiveDateTime.to_date(log.performed_at)
        Date.compare(log_date, from_date_parsed) != :lt and
        Date.compare(log_date, to_date_parsed) != :gt
      end)
    else
      socket.assigns.all_system_logs
    end

    paginated_logs = Enum.take(filtered_logs, socket.assigns.page_size)
    total_count = length(filtered_logs)
    total_pages = ceil(total_count / socket.assigns.page_size)

    {:noreply,
     assign(socket,
       system_logs: paginated_logs,
       filtered_system_logs: filtered_logs,
       total_count: total_count,
       total_pages: total_pages,
       current_page: 1,
       offset: 0,
       from_date: from_date,
       to_date: to_date,
       page_links: generate_page_links(1, total_pages)
     )}
  end

  def handle_event("reset_filters", _params, socket) do
    system_logs = SystemLogs.list_system_logs()
    total_count = length(system_logs)

    {:noreply,
     assign(socket,
       system_logs: Enum.take(system_logs, @page_size),
       all_system_logs: system_logs,
       filtered_system_logs: system_logs,
       total_count: total_count,
       total_pages: ceil(total_count / @page_size),
       current_page: 1,
       offset: 0,
       action_filter: "all",
       date_filter: "all",
       from_date: nil,
       to_date: nil,
       page_links: generate_page_links(1, ceil(total_count / @page_size))
     )}
  end

  defp generate_page_links(current_page, total_pages) do
    max_visible = 5
    half_visible = div(max_visible, 2)

    start_page = max(1, current_page - half_visible)
    end_page = min(total_pages, start_page + max_visible - 1)

    # Adjust start_page if we're near the end
    start_page = if end_page - start_page < max_visible - 1 do
      max(1, end_page - max_visible + 1)
    else
      start_page
    end

    Enum.to_list(start_page..end_page)
  end

  defp format_action(action) do
    case action do
      "approve_request" -> "Approved Request"
      "reject_request" -> "Rejected Request"
      "approve_return" -> "Approved Return"
      "reject_return" -> "Rejected Return"
      "resolve_report" -> "Resolved Report"
      "mark_pending" -> "Marked as Pending"
      "start_progress" -> "Started Progress"
      _ -> String.replace(action, "_", " ") |> String.capitalize()
    end
  end

  defp format_entity_type(entity_type) do
    case entity_type do
      "Request" -> "Request"
      "ReturnRequest" -> "Return Request"
      "Report" -> "Incident Report"
      _ -> entity_type
    end
  end
end
