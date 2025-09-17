defmodule MyKemudahanWeb.ReturnRequests.ReturnRequests do
  use MyKemudahanWeb, :live_view
  alias MyKemudahan.Requests
  alias MyKemudahan.Requests.ReturnRequest
  alias MyKemudahan.Repo
  import Ecto.Query

  def mount(_params, _session, socket) do
    return_requests = list_return_requests_with_associations("pending")

    {:ok, assign(socket,
      return_requests: return_requests,
      selected_request: nil,
      show_details: false,
      status_filter: "pending",
      show_remark_modal: false,
      remark_action: nil,
      remark_text: ""
    )}
  end

  # Helper function to query with associations
  defp list_return_requests_with_associations(status) do
    query = from rr in ReturnRequest,
      preload: [request: ^from(r in MyKemudahan.Requests.Request, preload: [:user, request_items: :asset])]

    case status do
      "all" -> Repo.all(query)
      "pending" -> Repo.all(from rr in query, where: rr.status == "pending")
      status -> Repo.all(from rr in query, where: rr.status == ^status)
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

  def handle_event("approve_return", params, socket) do
    return_request_id = params["id"]
    # Rest of your approve logic...
    case Requests.update_return_request_status(return_request_id, "approved") do
      {:ok, _} ->
        return_requests = list_return_requests_with_associations(socket.assigns.status_filter)
        {:noreply,
         assign(socket, return_requests: return_requests)
         |> put_flash(:info, "Return request approved successfully")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to approve return request")}
    end
  end

  def handle_event("reject_return", params, socket) do
    return_request_id = params["id"]
    # Rest of your reject logic...
    case Requests.update_return_request_status(return_request_id, "rejected") do
      {:ok, _} ->
        return_requests = list_return_requests_with_associations(socket.assigns.status_filter)
        {:noreply,
         assign(socket, return_requests: return_requests)
         |> put_flash(:info, "Return request rejected")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to reject return request")}
    end
  end
  def handle_event("close_details", _params, socket) do
    {:noreply, assign(socket, selected_request: nil, show_details: false)}
  end

  def handle_event("update_remark", %{"remark" => remark}, socket) do
    {:noreply, assign(socket, remark_text: remark)}
  end

  def handle_event("submit_remark", _params, socket) do
    case Requests.update_return_request_status(
      socket.assigns.selected_request_id,
      socket.assigns.remark_action,
      socket.assigns.remark_text
    ) do
      {:ok, _} ->
        return_requests = list_return_requests_with_associations(socket.assigns.status_filter)
        {:noreply,
         assign(socket,
           return_requests: return_requests,
           show_remark_modal: false,
           remark_action: nil,
           remark_text: "",
           selected_request_id: nil
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
end
