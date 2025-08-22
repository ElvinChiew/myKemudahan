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
    Repo.all(Request)
  end

  def list_user_requests(user_id) do
    from(r in Request,
    where: r.user_id == ^user_id,
    order_by: [desc: r.inserted_at])

    |> Repo.all()
  end

  def list_user_requests_by_status(user_id, status) do
    from(r in Request,
      where: r.user_id == ^user_id and r.status == ^status,
      order_by: [desc: r.inserted_at]
    )
    |> Repo.all()
  end

  # In lib/myKemudahan/requests.ex
def list_requests_by_status(status) do
  Request
  |> where(status: ^status)
  |> order_by(desc: :inserted_at)
  |> Repo.all()
end
end
