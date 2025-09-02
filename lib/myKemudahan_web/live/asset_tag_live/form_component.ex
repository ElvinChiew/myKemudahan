defmodule MyKemudahanWeb.AssetTagLive.FormComponent do
  use MyKemudahanWeb, :live_component

  alias MyKemudahan.Assets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-5 my-5 px-5 py-5">
      <.header>
        {@title}
        <:subtitle>Use this form to manage asset tag records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="asset_tag-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:tag]} type="text" label="Tag" />
        <.input field={@form[:serial]} type="text" label="Serial" />
        <.input field={@form[:status]} type="select" label="Status"
          options={[
            {"Available", "available"},
            {"Loaned", "loaned"},
            {"Damaged", "damaged"},
            {"Maintenance", "maintenance"}
          ]}
          />
        <:actions>
          <.button phx-disable-with="Saving...">Save Asset tag</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{asset_tag: asset_tag} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Assets.change_asset_tag(asset_tag))
     end)}
  end

  @impl true
  def handle_event("validate", %{"asset_tag" => asset_tag_params}, socket) do
    changeset = Assets.change_asset_tag(socket.assigns.asset_tag, asset_tag_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"asset_tag" => asset_tag_params}, socket) do
    save_asset_tag(socket, socket.assigns.action, asset_tag_params)
  end

  defp save_asset_tag(socket, :edit, asset_tag_params) do
    case Assets.update_asset_tag(socket.assigns.asset_tag, asset_tag_params) do
      {:ok, asset_tag} ->
        notify_parent({:saved, asset_tag})

        {:noreply,
         socket
         |> put_flash(:info, "Asset tag updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @doc """
  ## This is save new asset tag. since new asset tag is not allow to be created so not used
  defp save_asset_tag(socket, :new, asset_tag_params) do
    case Assets.create_asset_tag(asset_tag_params) do
      {:ok, asset_tag} ->
        notify_parent({:saved, asset_tag})

        {:noreply,
         socket
         |> put_flash(:info, "Asset tag created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
  """


  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
