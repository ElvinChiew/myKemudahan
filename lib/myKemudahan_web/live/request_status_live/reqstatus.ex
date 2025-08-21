defmodule MyKemudahanWeb.Reqstatus do

  alias MyKemudahan.Requests.Request
  alias MyKemudahan.Requests

  use MyKemudahanWeb, :live_view
  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    IO.inspect(user.full_name , label: "User Full Name")
    IO.inspect(user.id , label: "User id")

    requests = Requests.list_requests()  # Use your context function

    {:ok, assign(socket, requests: requests)}
  end
end
