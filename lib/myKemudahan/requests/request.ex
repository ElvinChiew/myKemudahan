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
    field :late_fee, :decimal
    field :status, :string
    field :rejection_reason, :string

    belongs_to :user, MyKemudahan.Accounts.User

    has_many :request_items, MyKemudahan.Requests.RequestItem
    has_many :reports, MyKemudahan.Reports.Report
    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:borrow_from, :borrow_to, :purpose, :total_cost, :discount_amount, :final_cost, :late_fee, :status, :user_id, :rejection_reason])
    |> validate_required([:borrow_from, :borrow_to, :purpose, :user_id])
    |> assoc_constraint(:user)
  end
end
