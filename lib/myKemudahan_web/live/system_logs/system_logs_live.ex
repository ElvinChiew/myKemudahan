defmodule MyKemudahanWeb.SystemLogsLive do
  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.SystemLogs
  import MyKemudahanWeb.AdminSidebar

  @per_page 20  # Logs per page

  def mount(_params, _session, socket) do
    system_logs = SystemLogs.list_system_logs()

    {:ok, assign(socket,
      system_logs: system_logs,
      filtered_system_logs: system_logs,
      action_filter: "all",
      date_filter: "all",
      from_date: nil,
      to_date: nil,
      page: 1,
      per_page: @per_page,
      total_pages: calc_total_pages(system_logs, @per_page)
    )}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, assign(socket, page: String.to_integer(page))}
  end

  def handle_event("filter_by_action", %{"action" => action}, socket) do
    filtered_logs = if action == "all" do
      socket.assigns.system_logs
    else
      Enum.filter(socket.assigns.system_logs, &(&1.action == action))
    end

    total_pages = calc_total_pages(filtered_logs, socket.assigns.per_page)

    {:noreply,
     assign(socket,
       filtered_system_logs: filtered_logs,
       total_pages: total_pages,
       page: 1,
       action_filter: action
     )}
  end

  def handle_event("filter_by_date", %{"date" => date}, socket) do
    filtered_logs = if date == "all" do
      socket.assigns.system_logs
    else
      today = Date.utc_today()
      case date do
        "today" ->
          Enum.filter(socket.assigns.system_logs, fn log ->
            log_date = NaiveDateTime.to_date(log.performed_at)
            Date.compare(log_date, today) == :eq
          end)
        "week" ->
          week_ago = Date.add(today, -7)
          Enum.filter(socket.assigns.system_logs, fn log ->
            log_date = NaiveDateTime.to_date(log.performed_at)
            Date.compare(log_date, week_ago) != :lt
          end)
        "month" ->
          month_ago = Date.add(today, -30)
          Enum.filter(socket.assigns.system_logs, fn log ->
            log_date = NaiveDateTime.to_date(log.performed_at)
            Date.compare(log_date, month_ago) != :lt
          end)
        _ ->
          socket.assigns.system_logs
      end
    end

    total_pages = calc_total_pages(filtered_logs, socket.assigns.per_page)

    {:noreply,
     assign(socket,
       filtered_system_logs: filtered_logs,
       total_pages: total_pages,
       page: 1,
       date_filter: date
     )}
  end

  def handle_event("filter_by_date_range", %{"from_date" => from_date, "to_date" => to_date}, socket) do
    filtered_logs = if from_date != "" and to_date != "" do
      from_date_parsed = Date.from_iso8601!(from_date)
      to_date_parsed = Date.from_iso8601!(to_date)

      Enum.filter(socket.assigns.system_logs, fn log ->
        log_date = NaiveDateTime.to_date(log.performed_at)
        Date.compare(log_date, from_date_parsed) != :lt and
        Date.compare(log_date, to_date_parsed) != :gt
      end)
    else
      socket.assigns.system_logs
    end

    total_pages = calc_total_pages(filtered_logs, socket.assigns.per_page)

    {:noreply,
     assign(socket,
       filtered_system_logs: filtered_logs,
       total_pages: total_pages,
       page: 1,
       from_date: from_date,
       to_date: to_date
     )}
  end

  def handle_event("reset_filters", _params, socket) do
    system_logs = SystemLogs.list_system_logs()

    {:noreply,
     assign(socket,
       system_logs: system_logs,
       filtered_system_logs: system_logs,
       total_pages: calc_total_pages(system_logs, @per_page),
       page: 1,
       action_filter: "all",
       date_filter: "all",
       from_date: nil,
       to_date: nil
     )}
  end

  defp calc_total_pages(logs, per_page) do
    (length(logs) / per_page) |> Float.ceil() |> round()
  end

  def paginate_logs(logs, page, per_page) do
    logs
    |> Enum.slice((page - 1) * per_page, per_page)
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
