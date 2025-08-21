defmodule MyKemudahanWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  alias MyKemudahanWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] && conn.assigns.current_user.role == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to access this page.")
      |> redirect(to: Routes.page_path(conn, :home))
      |> halt()
    end
  end
end
