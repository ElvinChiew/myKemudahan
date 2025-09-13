defmodule MyKemudahanWeb.UserLoginLive do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center px-4">
      <div class="flex w-full max-w-4xl rounded-xl bg-zinc-100 dark:bg-gray-950 text-950 dark:text-gray-300 overflow-hidden shadow-lg">

        <!-- Logo Section (hidden on small screens) -->
        <div class="hidden lg:flex flex-col items-center text-center bg-zinc-100 dark:bg-gray-950 px-8 py-10 lg:w-1/2">
          <img src={~p"/images/MK logo.png"} alt="logo" class="h-20 w-20 mb-4" />
          <p class="text-4xl font-bold mb-2">MyKemudahan</p>
          <p class="font-bold mb-6">Electronic Facility & Assets Requests and Management</p>
          <p class="text-sm leading-relaxed max-w-xs lg:max-w-none">
            Welcome to MyKemudahan. This is an electronic Facility & Assets Requests and Management system.
            If you have any questions or suggestions regarding this system, feel free to drop us a visit or call our phone.
          </p>
        </div>

        <!-- Login Form Section -->
        <div class="bg-slate-700 text-emerald-500 px-8 py-10 w-full lg:w-1/2 flex flex-col justify-center">
          <.header class="text-center mb-6">
            <p class="text-white font-bold text-3xl">Account Login</p>
          </.header>

          <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
            <.input field={@form[:email]} type="email" label="Email" required />
            <.input field={@form[:password]} type="password" label="Password" required />

            <:actions>
              <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
              <.link href={~p"/users/reset_password"} class="text-sm font-semibold text-emerald-400 hover:text-emerald-300">
                Forgot your password?
              </.link>
            </:actions>

            <:actions>
              <.button phx-disable-with="Logging in..." class="w-full mt-4">Log in</.button>
            </:actions>
          </.simple_form>

          <p class="text-xs text-white mt-6 text-center">
            Don’t have any account? Click
            <span class="text-teal-500 underline hover:text-teal-300 cursor-pointer"><a href="/users/register">here</a></span>
            to sign up. Terms and conditions apply. For more information please refer to our
            <span class="text-teal-500 underline hover:text-teal-300 cursor-pointer">FAQ</span>
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
