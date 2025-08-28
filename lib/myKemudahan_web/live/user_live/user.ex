defmodule MyKemudahanWeb.UserLive.User do
  alias MyKemudahan.Accounts
  use MyKemudahanWeb, :live_view
  alias MyKemudahan.Accounts
  import MyKemudahanWeb.AdminSidebar

  def mount(_params, _session, socket) do
    users = Accounts.list_all_user()
    {:ok, assign(socket, users: users)}
  end

  def handle_event("view_user_requests", %{"user_id" => user_id}, socket) do
    {:noreply, push_navigate(socket, to: "/admin/user-requests/#{user_id}")}
  end
end
