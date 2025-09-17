# lib/myKemudahan/requests/return_request.ex
defmodule MyKemudahan.Requests.ReturnRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "return_requests" do
    field :status, :string, default: "pending"
    field :submitted_at, :naive_datetime
    field :processed_at, :naive_datetime
    field :notes, :string
    field :admin_remarks, :string

    belongs_to :request, MyKemudahan.Requests.Request

    timestamps()
  end

  @doc false
  def changeset(return_request, attrs) do
    return_request
    |> cast(attrs, [:request_id, :status, :submitted_at, :processed_at, :notes, :admin_remarks])
    |> validate_required([:request_id, :submitted_at])
    |> validate_inclusion(:status, ["pending", "approved", "rejected"])
  end
end
