defmodule MyKemudahanWeb.UserSettingsLive do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex justify-center">
    <div class="px-5 py-5 bg-slate-700 space-y-6 rounded-xl shadow-xl mt-10 w-[25rem]">
      <!-- Tab Navigation -->
      <div class="flex space-x-4 border-b border-slate-500 mb-6">
        <button
          class={"pb-2 font-semibold " <> if @active_tab == "email", do: "border-b-2 border-white text-white", else: "text-slate-400"}
          phx-click="switch_tab"
          phx-value-tab="email"
        >
        <span class="mx-2"><i class="fa fa-user-circle text-white text-md" aria-hidden="true"></i></span>
          Update Name
        </button>
        <button
          class={"pb-2 font-semibold " <> if @active_tab == "password", do: "border-b-2 border-white text-white", else: "text-slate-400"}
          phx-click="switch_tab"
          phx-value-tab="password"
        >
        <span class="mx-2"><i class="fa fa-lock text-white text-md" aria-hidden="true"></i></span>
          Change Password
        </button>
      </div>
      <!-- Email Form -->
      <%= if @active_tab == "email" do %>
        <.simple_form
          for={@email_form}
          id="full_name_form"
          phx-submit="update_full_name"
        >
          <.label>
            <p class="text-3xl text-center font-bold">Edit Name</p>
          </.label>
           <.input field={@email_form[:full_name]} type="text" label="Full Name" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions><.button phx-disable-with="Changing...">Update Name</.button></:actions>
        </.simple_form>
      <% end %>
      <!-- Password Form -->
      <%= if @active_tab == "password" do %>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.label>
            <p class="text-3xl text-center font-bold">Update Password</p>
          </.label>
           <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions><.button phx-disable-with="Changing...">Change Password</.button></:actions>
        </.simple_form>
      <% end %>
    </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      # the default tab
      |> assign(:active_tab, "email")
      # |> assign(:full_name)
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event(
        "update_full_name",
        %{"current_password" => password, "user" => user_params},
        socket
      ) do
    user = socket.assigns.current_user

    case Accounts.update_user_full_name(user, password, user_params) do
      {:ok, updated_user} ->
        info = "Your full name has been updated successfully."

        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(email_form_current_password: nil)
         |> assign(:current_user, updated_user)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end
end
