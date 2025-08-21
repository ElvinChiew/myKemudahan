defmodule MyKemudahanWeb.UserRegistrationLive do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Accounts
  alias MyKemudahan.Accounts.User

  import MyKemudahanWeb.AdminSidebar

  def render(assigns) do
    ~H"""
    <.sidebar />
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
            <p class="text-white font-bold text-3xl">Register an account</p>
          </.header>

          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
          >
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>
             <.input field={@form[:email]} type="email" label="Email" required />
            <.input field={@form[:full_name]} type="text" label="Full Name" required />
            <.input field={@form[:password]} type="password" label="Password" required />
            <:actions>
              <.button phx-disable-with="Creating account..." class="w-full">
                Create an account
              </.button>
            </:actions>
          </.simple_form>

          <p class="text-xs text-white mt-5">
            By registering, you have agreed to our terms and conditions. Terms and condition applied. For more information please refer to our
            <span class="text-teal-500 underline hover:text-teal-300"><a href="/#">FAQ</a></span>
            page.
          </p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
