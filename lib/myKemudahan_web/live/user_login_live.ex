defmodule MyKemudahanWeb.UserLoginLive do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center px-4">
      <div class="flex flex-row items-stretch">
        <div class="hidden lg:flex w-[420px] h-[520px] rounded-xl bg-zinc-100 px-8 py-10 text-950 dark:bg-gray-950 dark:text-gray-300 justify-center">
          <div class="flex flex-col items-center text-center">
            <img src={~p"/images/MK logo.png"} alt="logo" class="h-23 w-23 mb-4" />
            <p class="text-4xl font-bold">MyKemudahan</p>

            <p class="font-bold">electronic Facility & Assets Requests and Management</p>

            <p class="mt-10">
              Welcome to MyKemudahan. This is an electronic Facility & Assets Requests and Managements.
              If you have any question or suggestions regarding to this system, feel free to drop us a visit or call our phone.
            </p>
          </div>
        </div>

        <div class="w-[420px] h-[520px] rounded-xl bg-slate-700 px-8 py-10 text-emerald-500">
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
              <.button phx-disable-with="Logging in..." class="w-full">Log in</.button>
            </:actions>
          </.simple_form>

          <p class="text-xs text-white mt-5">
            Don’t have any account? Click
            <span class="text-teal-500 underline hover:text-teal-300">here</span>
            to sign up. Terms and condition applied. For more information please refer to our
            <span class="text-teal-500 underline hover:text-teal-300">FAQ</span>
            page.
          </p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
