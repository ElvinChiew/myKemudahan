defmodule MyKemudahan.Requests do
  alias Ecto.Multi
  alias MyKemudahan.Repo
  alias MyKemudahan.Requests.{Request, RequestItem}

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
    from(i in RequestItem, where: i.request_id == ^request_id, preload: :item)
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
          request
          |> Ecto.Changeset.change(%{status: "approved"})
          |> Repo.update()
        else
          {:error, "Cannot approve request with status: #{request.status}"}
        end
    end
  end

  def reject_request(request_id) do
    case get_request!(request_id) do
      nil ->
        {:error, "Request not found"}

      request ->
        # Only allow rejection if status is sent or pending
        if request.status in ["sent", "pending"] do
          request
          |> Ecto.Changeset.change(%{status: "rejected"})
          |> Repo.update()
        else
          {:error, "Cannot reject request with status: #{request.status}"}
        end
    end
  end

  def list_request_items_by_request_id(request_id) do
    from(ri in RequestItem,
      where: ri.request_id == ^request_id,
      preload: [:asset]
    )
    |> Repo.all()
  end

end
