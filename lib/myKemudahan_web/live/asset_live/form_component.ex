defmodule MyKemudahanWeb.AssetLive.FormComponent do
  use MyKemudahanWeb, :live_component

  alias MyKemudahan.Assets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage asset records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="asset-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <div class="flex flex-row  justify-between">
          <div class="w-[12rem]">
          <.input field={@form[:cost_per_unit]} type="number" label="Cost per unit" step="any"/>
          </div>
          <div class="w-[12rem]">
          <.input field={@form[:status]} type="select" label="Status"
          options={[
            {"Available", "available"},
            {"Loaned", "loaned"},
            {"Damaged", "damaged"},
            {"Maintenance", "maintenance"}
          ]}
          />
          </div>
          <div class="w-[12rem]">
          <.input field={@form[:image]} type="text" label="Image" />
          </div>
        </div>
        <.input field={@form[:category_id]} type="select" label="Category" options={@category_options}/>
        <div class="flex flex-row justify-between">
          <div class="w-[13rem]">
            <.input field={@form[:name]} type="text" label="Asset Tag" />
          </div>
          <div class="w-[13rem]">
            <.input field={@form[:name]} type="text" label="Asset Serial No" />
          </div>
          <div class="">
          <.button> + </.button>
        </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Asset</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{asset: asset} = assigns, socket) do
    category_options =
      Assets.list_all_categories()
      |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:category_options, category_options)
     |> assign_new(:form, fn ->
       to_form(Assets.change_asset(asset))
     end)}
  end

  @impl true
  def handle_event("validate", %{"asset" => asset_params}, socket) do
    changeset = Assets.change_asset(socket.assigns.asset, asset_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"asset" => asset_params}, socket) do
    save_asset(socket, socket.assigns.action, asset_params)
  end

  defp save_asset(socket, :edit, asset_params) do
    case Assets.update_asset(socket.assigns.asset, asset_params) do
      {:ok, asset} ->
        notify_parent({:saved, asset})

        {:noreply,
         socket
         |> put_flash(:info, "Asset updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_asset(socket, :new, asset_params) do
    case Assets.create_asset(asset_params) do
      {:ok, asset} ->
        notify_parent({:saved, asset})

        {:noreply,
         socket
         |> put_flash(:info, "Asset created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
