defmodule MyKemudahanWeb.ReturnRequests.ReturnRequests do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Requests
  alias MyKemudahan.Requests.ReturnRequest
  alias MyKemudahan.Repo
  import Ecto.Query
  import MyKemudahanWeb.AdminSidebar

  def mount(_params, _session, socket) do
    # Update late fees for all overdue requests
    Requests.update_all_late_fees()

    return_requests = list_return_requests_with_associations("all")

    {:ok, assign(socket,
      return_requests: return_requests,
      selected_request: nil,
      show_details: false,
      status_filter: "all",
      show_remark_modal: false,
      remark_action: nil,
      remark_text: "",
      selected_request_id: nil
    )}
  end

  defp list_return_requests_with_associations(status) do
    base_query = from rr in ReturnRequest,
      preload: [request: ^from(r in MyKemudahan.Requests.Request, preload: [:user, request_items: :asset])],
      order_by: [desc: rr.inserted_at]

    case status do
      "all" -> Repo.all(base_query)
      "pending" -> Repo.all(from rr in base_query, where: rr.status == "pending")
      status -> Repo.all(from rr in base_query, where: rr.status == ^status)
    end
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    return_requests = list_return_requests_with_associations(status)

    {:noreply, assign(socket,
      return_requests: return_requests,
      status_filter: status
    )}
  end

  def handle_event("show_details", %{"id" => return_request_id}, socket) do
    return_request = Repo.get!(ReturnRequest, return_request_id)
    |> Repo.preload([request: [:user, request_items: :asset]])

    {:noreply, assign(socket, selected_request: return_request, show_details: true)}
  end

  def handle_event("open_remark_modal", %{"id" => id, "action" => action}, socket) do
    {:noreply, assign(socket,
      show_remark_modal: true,
      remark_action: action,
      selected_request_id: id,
      remark_text: ""
    )}
  end

  def handle_event("approve_return", %{"id" => id}, socket) do
    {:noreply, assign(socket,
      show_remark_modal: true,
      remark_action: "approved",
      selected_request_id: id,
      remark_text: ""
    )}
  end

  def handle_event("reject_return", %{"id" => id}, socket) do
    {:noreply, assign(socket,
      show_remark_modal: true,
      remark_action: "rejected",
      selected_request_id: id,
      remark_text: ""
    )}
  end

  def handle_event("close_details", _params, socket) do
    {:noreply, assign(socket, selected_request: nil, show_details: false)}
  end

  def handle_event("update_remark", %{"remark" => remark}, socket) do
    {:noreply, assign(socket, remark_text: remark)}
  end

  def handle_event("submit_remark", %{"remark" => remark}, socket) do
    case Requests.update_return_request_status(
      socket.assigns.selected_request_id,
      socket.assigns.remark_action,
      remark
    ) do
      {:ok, _} ->
        return_requests = list_return_requests_with_associations(socket.assigns.status_filter)
        {:noreply,
         assign(socket,
           return_requests: return_requests,
           show_remark_modal: false,
           remark_action: nil,
           remark_text: "",
           selected_request_id: nil,
           selected_request: nil,
           show_details: false
         )
         |> put_flash(:info, "Return request #{socket.assigns.remark_action} successfully")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update return request")}
    end
  end

  def handle_event("cancel_remark", _params, socket) do
    {:noreply, assign(socket,
      show_remark_modal: false,
      remark_action: nil,
      remark_text: "",
      selected_request_id: nil
    )}
  end

  def handle_event("change_status", %{"id" => id, "status" => new_status}, socket) do
    # Allow changing status from rejected to approved or vice versa
    case Requests.update_return_request_status(id, new_status, "Status changed by admin") do
      {:ok, _} ->
        return_requests = list_return_requests_with_associations(socket.assigns.status_filter)
        {:noreply,
         assign(socket, return_requests: return_requests)
         |> put_flash(:info, "Status updated successfully")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
    end
  end

  def handle_event("reset_filters", _params, socket) do
    return_requests = list_return_requests_with_associations("all")

    {:noreply, assign(socket,
      return_requests: return_requests,
      status_filter: "all"
    )}
  end
end
