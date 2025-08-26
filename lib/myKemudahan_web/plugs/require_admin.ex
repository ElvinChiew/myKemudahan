defmodule MyKemudahanWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = conn.assigns[:current_user]

    if current_user && current_user.role == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "Access Denied!")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
