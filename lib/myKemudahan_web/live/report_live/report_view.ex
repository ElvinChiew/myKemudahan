defmodule MyKemudahanWeb.ReportLive.ReportView do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Reports
  alias MyKemudahan.Reports.Report
  import MyKemudahanWeb.AdminSidebar

  @page_size 10

  def mount(_params, _session, socket) do
    reports = Reports.list_report()
    total_count = length(reports)
    page_links = generate_page_links(1, ceil(total_count / @page_size))

    socket = assign(socket,
      reports: Enum.take(reports, @page_size),
      all_reports: reports,
      total_count: total_count,
      page_size: @page_size,
      current_page: 1,
      total_pages: ceil(total_count / @page_size),
      offset: 0,
      page_links: page_links
    )

    {:ok, socket}
  end

  def handle_event("paginate", %{"page" => page_str}, socket) do
    page = String.to_integer(page_str)
    offset = (page - 1) * socket.assigns.page_size

    paginated_reports =
      socket.assigns.all_reports
      |> Enum.drop(offset)
      |> Enum.take(socket.assigns.page_size)

    # Generate page links for pagination (showing up to 5 pages)
    page_links = generate_page_links(page, socket.assigns.total_pages)

    {:noreply, assign(socket,
      reports: paginated_reports,
      current_page: page,
      offset: offset,
      page_links: page_links
    )}
  end

  def handle_event("update_status", %{"id" => id, "status" => new_status}, socket) do
    # Update the report status in the database
    report = Reports.get_report!(id)

    case Reports.update_report(report, %{status: new_status}) do
      {:ok, updated_report} ->
        # Update the report in the all_reports list
        updated_reports = Enum.map(socket.assigns.all_reports, fn r ->
          if r.id == updated_report.id, do: updated_report, else: r
        end)

        # Update the current page reports
        offset = socket.assigns.offset
        current_reports =
          updated_reports
          |> Enum.drop(offset)
          |> Enum.take(socket.assigns.page_size)

        {:noreply, assign(socket,
          all_reports: updated_reports,
          reports: current_reports
        )}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
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
end
