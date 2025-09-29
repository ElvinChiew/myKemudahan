defmodule MyKemudahanWeb.ReturnRequests.ReturnRequests do
  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  alias MyKemudahan.Requests
  alias MyKemudahan.Requests.ReturnRequest
  alias MyKemudahan.Repo
  import Ecto.Query
  import MyKemudahanWeb.AdminSidebar

  @per_page 10  # Return requests per page

  def mount(_params, _session, socket) do
    # Update late fees for all overdue requests
    Requests.update_all_late_fees()

    return_requests = list_return_requests_with_associations("all")

    {:ok, assign(socket,
      return_requests: return_requests,
      filtered_return_requests: return_requests,
      selected_request: nil,
      show_details: false,
      status_filter: "all",
      show_remark_modal: false,
      remark_action: nil,
      remark_text: "",
      selected_request_id: nil,
      page: 1,
      per_page: @per_page,
      total_pages: calc_total_pages(return_requests, @per_page)
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
    total_pages = calc_total_pages(return_requests, socket.assigns.per_page)

    {:noreply, assign(socket,
      return_requests: return_requests,
      filtered_return_requests: return_requests,
      status_filter: status,
      page: 1,
      total_pages: total_pages
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
        # Log admin action for transparency
        try do
          action = if socket.assigns.remark_action == "approved", do: "approve_return", else: "reject_return"
          IO.inspect({socket.assigns.current_user.id, action, "ReturnRequest", socket.assigns.selected_request_id}, label: "Logging return action")
          MyKemudahan.SystemLogs.log_admin_action(
            socket.assigns.current_user.id,
            action,
            "ReturnRequest",
            socket.assigns.selected_request_id,
            "Return request #{socket.assigns.remark_action} by admin. Remark: #{remark}"
          )
        rescue
          error ->
            IO.inspect(error, label: "System logging failed")
        end

        return_requests = list_return_requests_with_associations(socket.assigns.status_filter)
        total_pages = calc_total_pages(return_requests, socket.assigns.per_page)
        {:noreply,
         assign(socket,
           return_requests: return_requests,
           filtered_return_requests: return_requests,
           total_pages: total_pages,
           page: 1,
           show_remark_modal: false,
           remark_action: nil,
           remark_text: "",
           selected_request_id: nil,
           selected_request: nil,
           show_details: false
         )
         |> put_flash(:info, "Return request #{socket.assigns.remark_action} successfully")}

      {:error, reason} ->
        error_message = case reason do
          :not_found -> "Return request not found"
          reason when is_binary(reason) -> reason
          _ -> "Failed to update return request"
        end
        {:noreply, put_flash(socket, :error, error_message)}
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
        total_pages = calc_total_pages(return_requests, socket.assigns.per_page)
        {:noreply,
         assign(socket,
           return_requests: return_requests,
           filtered_return_requests: return_requests,
           total_pages: total_pages,
           page: 1
         )
         |> put_flash(:info, "Status updated successfully")}

      {:error, reason} ->
        error_message = case reason do
          :not_found -> "Return request not found"
          reason when is_binary(reason) -> reason
          _ -> "Failed to update status"
        end
        {:noreply, put_flash(socket, :error, error_message)}
    end
  end

  def handle_event("reset_filters", _params, socket) do
    return_requests = list_return_requests_with_associations("all")
    total_pages = calc_total_pages(return_requests, socket.assigns.per_page)

    {:noreply, assign(socket,
      return_requests: return_requests,
      filtered_return_requests: return_requests,
      status_filter: "all",
      page: 1,
      total_pages: total_pages
    )}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, assign(socket, page: String.to_integer(page))}
  end

  defp calc_total_pages(return_requests, per_page) do
    (length(return_requests) / per_page) |> Float.ceil() |> round()
  end

  def paginate_return_requests(return_requests, page, per_page) do
    return_requests
    |> Enum.slice((page - 1) * per_page, per_page)
  end
end
