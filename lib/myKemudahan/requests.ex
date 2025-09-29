defmodule MyKemudahan.Requests do
  alias Ecto.Multi
  alias MyKemudahan.Repo
  alias MyKemudahan.Requests.{Request, RequestItem, ReturnRequest}
  alias MyKemudahan.Assets

  import Ecto.Query
  def create_request_with_items(attrs, items) do
    Multi.new()
    |> Multi.insert(:request, Request.changeset(%Request{}, attrs))
    |> Multi.run(:items, fn repo, %{request: request} ->
      item_maps =
        Enum.map(items, fn item ->
          %{
            quantity: item.quantity,
            cost_per_unit: item.cost_per_unit,
            asset_id: item.id,
            request_id: request.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second) ,
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          }
        end)

        case repo.insert_all(RequestItem, item_maps) do
          {count, _} when is_integer(count) -> {:ok, item_maps}
          error -> {:error, error}
        end
    end)
    |> Repo.transaction()
  end

  def list_all_requests do
    Request
    |> preload(:user)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  # Fetch requests that are due tomorrow (borrow_to is tomorrow) and are active/approved
  def list_requests_due_tomorrow do
    tomorrow = Date.utc_today() |> Date.add(1)

    from(r in Request,
      where: r.borrow_to == ^tomorrow and r.status in ["approved", "sent", "pending"],
      preload: [:user, request_items: :asset]
    )
    |> Repo.all()
  end

  def list_user_requests(user_id) do
    from(r in Request,
    where: r.user_id == ^user_id,
    preload: [:user],
    order_by: [desc: r.inserted_at])

    |> Repo.all()
  end

  def list_user_requests_by_status(user_id, status) do
    from(r in Request,
      where: r.user_id == ^user_id and r.status == ^status,
      preload: [:user],
      order_by: [desc: r.inserted_at]
    )
    |> Repo.all()
  end

  # In lib/myKemudahan/requests.ex
def list_requests_by_status(status) do
  Request
  |> where(status: ^status)
  |> preload(:user)
  |> order_by(desc: :inserted_at)
  |> Repo.all()
end

  # Add this function to get a single request by ID
  def get_request!(id) do
    Request
    |> where(id: ^id)
    |> preload([:user, request_items: :asset])
    |> Repo.one!()
  end

  def list_request_items(request_id) do
    from(i in RequestItem, where: i.request_id == ^request_id, preload: :asset)
    |> Repo.all()
  end

  def cancel_request(request_id) do
    case Repo.get(Request, request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        # Only allow cancellation if status is sent or pending
        if request.status in ["sent", "pending"] do
          request
          |> Ecto.Changeset.change(%{status: "cancelled"})
          |> Repo.update()
        else
          {:error, "Cannot cancel request with status: #{request.status}"}
        end
    end
  end

  def apply_discount(request_id, discount_amount) do
    case get_request!(request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        total_cost = request.total_cost || Decimal.new("0")
        discount = Decimal.new(discount_amount)

        # Ensure discount doesn't exceed total cost
        final_discount = if Decimal.compare(discount, total_cost) == :gt do
          total_cost
        else
          discount
        end

        final_cost = Decimal.sub(total_cost, final_discount)

        request
        |> Ecto.Changeset.change(%{
          discount_amount: final_discount,
          final_cost: final_cost
        })
        |> Repo.update()
    end
  end

  def remove_discount(request_id) do
    case get_request!(request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        request
        |> Ecto.Changeset.change(%{
          discount_amount: nil,
          final_cost: request.total_cost
        })
        |> Repo.update()
    end
  end

# In lib/myKemudahan/requests.ex

  def approve_request(request_id) do
    case get_request!(request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        # Only allow approval if status is sent or pending
        if request.status in ["sent", "pending"] do
          # Update asset tags for each request item
          request_items = list_request_items(request_id)

          # Update asset tags for each item
          asset_update_results = Enum.map(request_items, fn item ->
            Assets.update_asset_tag_for_approval(item.asset_id, item.quantity)
          end)

          # Check if any asset updates failed
          failed_updates = Enum.filter(asset_update_results, fn
            {:error, _} -> true
            _ -> false
          end)

          if length(failed_updates) > 0 do
            {:error, "Failed to update asset tags: #{inspect(failed_updates)}"}
          else
            # Update request status to approved
            request
            |> Ecto.Changeset.change(%{status: "approved"})
            |> Repo.update()
          end
        else
          {:error, "Cannot approve request with status: #{request.status}"}
        end
    end
  end

  def reject_request(id, reason) do
    case get_request!(id) do
      nil -> {:error, "Request not found"}
      request ->
        request
        |> Ecto.Changeset.change(%{status: "rejected", rejection_reason: reason})
        |> Repo.update()
    end
  end

  def list_request_items_by_request_id(request_id) do
    from(ri in RequestItem,
      where: ri.request_id == ^request_id,
      preload: [:asset]
    )
    |> Repo.all()
  end

  def get_request_with_items!(id) do
    Request
    |> where(id: ^id)
    |> preload([:user, request_items: [:asset]])
    |> Repo.one!()
  end

  # Add these functions to your context
  def submit_return_request(request_id, notes \\ nil) do
    case get_request!(request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        # Check if request is approved or overdue and doesn't already have a return request
        if request.status not in ["approved", "overdue"] do
          {:error, "Only approved or overdue requests can be returned"}
        else
          case get_return_request_by_request_id(request_id) do
            nil ->
              # Create new return request
              %ReturnRequest{}
              |> ReturnRequest.changeset(%{
                request_id: request_id,
                submitted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
                notes: notes
              })
              |> Repo.insert()

            _existing_request ->
              {:error, "Return request already exists for this request"}
          end
        end
    end
  end

  def get_return_request_by_request_id(request_id) do
    from(rr in ReturnRequest, where: rr.request_id == ^request_id)
    |> Repo.one()
  end

  def update_return_request_status(id, new_status, admin_remarks) do
    case Repo.get(ReturnRequest, id) do
      nil ->
        {:error, :not_found}

      return_request ->
        # If approving the return, update asset tags back to available and change request status
        if new_status == "approved" do
          # Get the original request and its items
          original_request = get_request!(return_request.request_id)
          request_items = list_request_items(original_request.id)

          # Update asset tags for each item back to available
          asset_update_results = Enum.map(request_items, fn item ->
            Assets.update_asset_tag_for_return(item.asset_id, item.quantity)
          end)

          # Check if any asset updates failed
          failed_updates = Enum.filter(asset_update_results, fn
            {:error, _} -> true
            _ -> false
          end)

          if length(failed_updates) > 0 do
            {:error, "Failed to update asset tags: #{inspect(failed_updates)}"}
          else
            # Update return request status
            return_request
            |> ReturnRequest.changeset(%{
              status: new_status,
              processed_at: NaiveDateTime.utc_now(),
              admin_remarks: admin_remarks
            })
            |> Repo.update()
            |> case do
              {:ok, updated_return_request} ->
                # Update the original request status to "returned"
                original_request
                |> Ecto.Changeset.change(%{status: "returned"})
                |> Repo.update()
                |> case do
                  {:ok, _} -> {:ok, updated_return_request}
                  {:error, changeset} -> {:error, changeset}
                end
              error -> error
            end
          end
        else
          # For rejected returns, just update the status
          return_request
          |> ReturnRequest.changeset(%{
            status: new_status,
            processed_at: NaiveDateTime.utc_now(),
            admin_remarks: admin_remarks
          })
          |> Repo.update()
        end
    end
  end

  def list_all_return_requests do
    from(rr in ReturnRequest,
      preload: [request: [:user]],
      order_by: [desc: rr.inserted_at])
    |> Repo.all()
  end


  def list_pending_return_requests do
    ReturnRequest
    |> where(status: "pending")
    |> preload([request: :user])
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_return_requests_by_status(status) do
    ReturnRequest
    |> where(status: ^status)
    |> preload([request: :user])
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_return_request_with_details!(id) do
    ReturnRequest
    |> where(id: ^id)
    |> preload([request: [:user, request_items: :asset]])
    |> Repo.one!()
  end

  def create_return_request(attrs) do
    %ReturnRequest{}
    |> ReturnRequest.changeset(attrs)
    |> Repo.insert()
  end

  def resubmit_return_request(request_id, notes \\ nil) do
    case get_return_request_by_request_id(request_id) do
      nil ->
        {:error, "Return request not found"}

      return_request ->
        if return_request.status != "rejected" do
          {:error, "Only rejected return requests can be resubmitted"}
        else
          # Update the return request to pending status with new notes
          return_request
          |> ReturnRequest.changeset(%{
            status: "pending",
            submitted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            notes: notes,
            processed_at: nil,
            admin_remarks: nil
          })
          |> Repo.update()
        end
    end
  end

  # Calculate late fee for a request based on due date
  def calculate_late_fee(request) do
    today = Date.utc_today()

    if Date.compare(today, request.borrow_to) == :gt do
      days_late = Date.diff(today, request.borrow_to)
      late_fee_per_day = Decimal.new("10")
      Decimal.mult(late_fee_per_day, Decimal.new(days_late))
    else
      Decimal.new("0")
    end
  end

  # Update late fee for a specific request
  def update_late_fee(request_id) do
    case get_request!(request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        new_late_fee = calculate_late_fee(request)

        request
        |> Ecto.Changeset.change(%{late_fee: new_late_fee})
        |> Repo.update()
    end
  end

  # Update late fees for all overdue requests and update status
  def update_all_late_fees do
    today = Date.utc_today()

    # Get all approved requests that are overdue
    overdue_requests = from(r in Request,
      where: r.status == "approved" and r.borrow_to < ^today,
      preload: [:user]
    )
    |> Repo.all()

    # Update late fees and status for each overdue request
    Enum.map(overdue_requests, fn request ->
      new_late_fee = calculate_late_fee(request)

      request
      |> Ecto.Changeset.change(%{
        late_fee: new_late_fee,
        status: "overdue"
      })
      |> Repo.update()
    end)
  end

  # Check if a request is overdue
  def is_overdue?(request) do
    today = Date.utc_today()
    # A request is overdue if it's past the due date and not yet returned
    Date.compare(today, request.borrow_to) == :gt and request.status != "returned"
  end

  # Get days overdue for a request
  def days_overdue(request) do
    today = Date.utc_today()

    if Date.compare(today, request.borrow_to) == :gt and request.status != "returned" do
      Date.diff(today, request.borrow_to)
    else
      0
    end
  end
end
