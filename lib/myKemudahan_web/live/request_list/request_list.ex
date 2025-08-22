defmodule MyKemudahanWeb.RequestList do
  alias MyKemudahan.Requests.Request
  alias MyKemudahan.Requests
  alias MyKemudahan.Repo

  import MyKemudahanWeb.AdminSidebar

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    # For admin view, we'll show all requests, not just the current user's
    requests = Requests.list_all_requests()

  # Calculate status counts
  status_counts = %{
    total: length(requests),
    sent: count_by_status(requests, "sent"),
    pending: count_by_status(requests, "pending"),
    approved: count_by_status(requests, "approved"),
    rejected: count_by_status(requests, "rejected")
  }

    socket =
      socket
      |> assign(:requests, requests)
      |> assign(:status_filter, "all")
      |> assign(:status_counts, status_counts)
      |> assign(:page_title, "Admin - All Requests")
      |> assign(:all_requests, requests)

    {:ok, socket}
  end

  # Handle Tabs Click
  def handle_event("filter_status", %{"status" => status}, socket) do

    all_requests = Requests.list_all_requests()

    filtered_requests =
      case status do
        "all" -> all_requests
        _ -> Requests.list_requests_by_status(status)
      end

    status_counts = %{
      total: length(all_requests),
      sent: Enum.count(all_requests, &(&1.status == "sent")),
      pending: Enum.count(all_requests, &(&1.status == "pending")),
      approved: Enum.count(all_requests, &(&1.status == "approved")),
      rejected: Enum.count(all_requests, &(&1.status == "rejected"))
    }

    {:noreply,
      assign(socket,
        requests: filtered_requests,
        status_filter: status,
        status_counts: status_counts
      )}
  end

  defp percentage(part, whole) when whole > 0 do
    round((part / whole) * 100)
  end

  defp percentage(_part, _whole), do: 0

  defp count_by_status(requests, status) do
    Enum.count(requests, &(&1.status == status))
  end
end
