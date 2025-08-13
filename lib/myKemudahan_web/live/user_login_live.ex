defmodule MyKemudahanWeb.UserLoginLive do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm bg-slate-700 px-5 py-10 rounded-lg text-emerald-500">
      <.header class="text-center">
        <p class="text-white font-bold text-3xl">Account Login</p>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-xs text-white mt-5">Don’t have any account? Click
        <span class="text-teal-500 underline hover:text-teal-300">here</span>
        to sign up. Terms and condition applied. For more information please refer to our
        <span class="text-teal-500 underline hover:text-teal-300">FAQ</span>
        page.
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
