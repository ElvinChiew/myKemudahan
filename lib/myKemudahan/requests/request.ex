defmodule MyKemudahan.Requests.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :borrow_from, :date
    field :borrow_to, :date
    field :purpose, :string
    field :total_cost, :decimal
    field :discount_amount, :decimal
    field :final_cost, :decimal
    field :status, :string

    belongs_to :user, MyKemudahan.Accounts.User

    has_many :request_items, MyKemudahan.Requests.RequestItem

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:borrow_from, :borrow_to, :purpose, :total_cost])
    |> validate_required([:borrow_from, :borrow_to, :purpose])
  end
end
