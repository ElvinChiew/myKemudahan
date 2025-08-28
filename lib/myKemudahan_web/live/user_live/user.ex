defmodule MyKemudahanWeb.UserLive.User do
  alias MyKemudahan.Accounts
  use MyKemudahanWeb, :live_view
  import MyKemudahanWeb.AdminSidebar

  @per_page 10  # Users per page

  def mount(_params, _session, socket) do
    users = Accounts.list_all_user()

    {:ok, assign(socket,
      users: users,
      filtered_users: users,
      search: "",
      role_filter: "all",
      page: 1,
      per_page: @per_page,
      total_pages: calc_total_pages(users, @per_page)
    )}
  end

  def handle_event("search", %{"search" => search}, socket) do
    filtered_users = filter_users(socket.assigns.users, search, socket.assigns.role_filter)
    total_pages = calc_total_pages(filtered_users, socket.assigns.per_page)

    {:noreply, assign(socket,
      search: search,
      filtered_users: filtered_users,
      page: 1,
      total_pages: total_pages
    )}
  end

  def handle_event("filter_role", %{"role" => role}, socket) do
    filtered_users = filter_users(socket.assigns.users, socket.assigns.search, role)
    total_pages = calc_total_pages(filtered_users, socket.assigns.per_page)

    {:noreply, assign(socket,
      role_filter: role,
      filtered_users: filtered_users,
      page: 1,
      total_pages: total_pages
    )}
  end

  def handle_event("view_user_requests", %{"user_id" => user_id}, socket) do
    {:noreply, push_navigate(socket, to: "/admin/user-requests/#{user_id}")}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, assign(socket, page: String.to_integer(page))}
  end

  defp filter_users(users, search, role_filter) do
    users
    |> Enum.filter(fn user ->
      String.downcase(user.full_name) =~ String.downcase(search) &&
      (role_filter == "all" || user.role == role_filter)
    end)
  end

  defp calc_total_pages(users, per_page) do
    (length(users) / per_page) |> Float.ceil() |> round()
  end

  defp paginate_users(users, page, per_page) do
    users
    |> Enum.slice((page - 1) * per_page, per_page)
  end
end
