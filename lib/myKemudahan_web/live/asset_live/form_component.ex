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

        <div class="space-y-4">
          <label class="block text-sm font-medium text-white">Asset Tags & Serial Numbers</label>
          <%= for {tag, index} <- Enum.with_index(@asset_tags) do %>
            <div class="flex flex-row justify-between items-end gap-4">
              <div class="w-[13rem]">
                <label class="block text-sm font-medium text-white">Asset Tag</label>
                <input
                  type="text"
                  name="asset_tags[#{index}][tag]"
                  value={tag[:tag] || ""}
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  placeholder="Enter asset tag"
                />
              </div>
              <div class="w-[13rem]">
                <label class="block text-sm font-medium text-white">Asset Serial No</label>
                <input
                  type="text"
                  name="asset_tags[#{index}][serial_number]"
                  value={tag[:serial_number] || ""}
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  placeholder="Enter serial number"
                />
              </div>
              <div class="flex gap-2">
                <button
                  type="button"
                  phx-click="add-asset-tag"
                  phx-target={@myself}
                  class="bg-teal-500 text-white rounded-full px-3 py-2 hover:bg-teal-600"
                >
                  +
                </button>
                <%= if length(@asset_tags) > 1 do %>
                  <button
                    type="button"
                    phx-click="remove-asset-tag"
                    phx-value-index={index}
                    phx-target={@myself}
                    class="bg-red-500 text-white rounded-full px-3 py-2 hover:bg-red-600"
                  >
                    -
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>
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

    # Handle asset_tags properly - check if it's loaded and handle the NotLoaded case
    asset_tags = case asset.asset_tags do
      %Ecto.Association.NotLoaded{} -> [%{tag: "", serial_number: ""}]
      tags when is_list(tags) and length(tags) == 0 -> [%{tag: "", serial_number: ""}]
      tags when is_list(tags) ->
        tags |> Enum.map(fn tag ->
          %{tag: tag.tag || "", serial_number: tag.serial || ""}
        end)
      _ -> [%{tag: "", serial_number: ""}]
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:asset_tags, asset_tags)
     |> assign(:category_options, category_options)
     |> assign_new(:form, fn ->
       to_form(Assets.change_asset(asset))
     end)}
  end

  @impl true
  def handle_event("validate", %{"asset" => asset_params} = all_params, socket) do
    # Update asset_tags from form data to preserve user input
    asset_tags = parse_asset_tags_from_form(all_params)

    changeset = Assets.change_asset(socket.assigns.asset, asset_params)

    {:noreply,
     socket
     |> assign(:asset_tags, asset_tags)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"asset" => asset_params} = all_params, socket) do
    # Debug: Log save parameters
    IO.puts("=== SAVE EVENT TRIGGERED ===")
    IO.inspect(all_params, label: "All save params")

    # Extract asset_tags from the form data
    asset_tags = parse_asset_tags(all_params)
    IO.inspect(asset_tags, label: "Parsed asset tags for database")

    asset_params_with_tags = Map.put(asset_params, "asset_tags", asset_tags)
    IO.inspect(asset_params_with_tags, label: "Final asset params with tags")

    save_asset(socket, socket.assigns.action, asset_params_with_tags)
  end

  @impl true
  def handle_event("add-asset-tag", _params, socket) do
    # Get current form data to preserve existing values
    current_tags = socket.assigns.asset_tags
    updated_tags = current_tags ++ [%{tag: "", serial_number: ""}]
    {:noreply, assign(socket, :asset_tags, updated_tags)}
  end

  def handle_event("remove-asset-tag", %{"index" => index}, socket) do
    index = String.to_integer(index)
    current_tags = socket.assigns.asset_tags
    updated_tags = List.delete_at(current_tags, index)

    # Ensure we always have at least one set of fields
    final_tags = if updated_tags == [], do: [%{tag: "", serial_number: ""}], else: updated_tags

    {:noreply, assign(socket, :asset_tags, final_tags)}
  end

  defp save_asset(socket, :edit, asset_params) do
    IO.inspect(asset_params, label: "Saving asset (edit) with params")
    case Assets.update_asset(socket.assigns.asset, asset_params) do
      {:ok, asset} ->
        notify_parent({:saved, asset})

        {:noreply,
         socket
         |> put_flash(:info, "Asset updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "Validation errors (edit)")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_asset(socket, :new, asset_params) do
    IO.inspect(asset_params, label: "Saving asset (new) with params")
    case Assets.create_asset(asset_params) do
      {:ok, asset} ->
        notify_parent({:saved, asset})

        {:noreply,
         socket
         |> put_flash(:info, "Asset created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "Validation errors (new)")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp parse_asset_tags(all_params) do
    asset_params = Map.get(all_params, "asset", %{})
    status = asset_params["status"] || "available"

    case Map.get(all_params, "asset_tags") do
      nil -> []
      tags when is_map(tags) ->
        # Convert indexed map to list format for database
        tags
        |> Map.keys()
        |> Enum.sort()
        |> Enum.map(fn key ->
          tag = tags[key]
          %{
            "tag" => tag["tag"] || "",
            "serial" => tag["serial_number"] || "",
            "status" => status
          }
        end)
        |> Enum.filter(fn tag ->
          tag["tag"] != "" || tag["serial"] != ""
        end)
      tags when is_list(tags) ->
        tags
        |> Enum.filter(fn tag ->
          tag["tag"] != "" || tag["serial_number"] != ""
        end)
        |> Enum.map(fn tag ->
          %{
            "tag" => tag["tag"] || "",
            "serial" => tag["serial_number"] || "",
            "status" => status
          }
        end)
    end
  end

  defp parse_asset_tags_from_form(all_params) do
    case Map.get(all_params, "asset_tags") do
      nil -> [%{tag: "", serial_number: ""}]
      tags when is_map(tags) ->
        # Convert indexed map to list format for form state
        tags
        |> Map.keys()
        |> Enum.sort()
        |> Enum.map(fn key ->
          tag = tags[key]
          %{
            tag: tag["tag"] || "",
            serial_number: tag["serial_number"] || ""
          }
        end)
        |> then(fn list -> if list == [], do: [%{tag: "", serial_number: ""}], else: list end)
      tags when is_list(tags) ->
        tags
        |> Enum.map(fn tag ->
          %{
            tag: tag["tag"] || "",
            serial_number: tag["serial_number"] || ""
          }
        end)
        |> then(fn list -> if list == [], do: [%{tag: "", serial_number: ""}], else: list end)
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
