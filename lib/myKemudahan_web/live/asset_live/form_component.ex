defmodule MyKemudahanWeb.AssetLive.FormComponent do
  use MyKemudahanWeb, :live_component

  alias MyKemudahan.Assets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold text-black mb-1"><%= @title %></h2>
      <p class="text-sm text-gray-300 mb-6">Use this form to manage asset records in your database.</p>

      <form
        id="asset-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        class="space-y-6"
      >
        <!-- Name -->
        <div>
          <label for="name" class="block text-sm font-medium text-black">Name</label>
          <input
            type="text"
            id="name"
            name="asset[name]"
            value={@form[:name].value}
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          />
        </div>

        <!-- Description -->
        <div>
          <label for="description" class="block text-sm font-medium text-black">Description</label>
          <input
            type="text"
            id="description"
            name="asset[description]"
            value={@form[:description].value}
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          />
        </div>

        <!-- Cost, Status, Image Upload -->
        <div class="flex flex-row justify-between gap-4">
          <!-- Cost per unit -->
          <div class="w-[12rem]">
            <label class="block text-sm font-medium text-black">Cost per unit</label>
            <input
              type="number"
              name="asset[cost_per_unit]"
              value={@form[:cost_per_unit].value}
              step="any"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
            />
          </div>

          <!-- Status -->
          <div class="w-[12rem]">
            <label class="block text-sm font-medium text-black">Status</label>
            <select
              name="asset[status]"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
            >
              <%= Phoenix.HTML.Form.options_for_select([
                {"Available", "available"},
                {"Loaned", "loaned"},
                {"Damaged", "damaged"},
                {"Maintenance", "maintenance"}
              ], @form[:status].value) %>
            </select>
          </div>

          <!-- Image Upload -->
          <div class="w-[12rem]">
            <label class="block text-sm font-medium text-black mb-2">Image Upload</label>
            <.live_file_input upload={@uploads.image} />
          </div>
        </div>

        <!-- Category -->
        <div>
          <label class="block text-sm font-medium text-black">Category</label>
          <select
            name="asset[category_id]"
            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
          >
            <%= Phoenix.HTML.Form.options_for_select(@category_options, @form[:category_id].value) %>
          </select>
        </div>

        <!-- Asset Tags & Serial Numbers -->
        <div class="space-y-4">
          <label class="block text-sm font-medium text-black">Asset Tags & Serial Numbers</label>

          <%= for {tag, index} <- Enum.with_index(@asset_tags) do %>
            <div class="flex flex-row justify-between items-end gap-4">
              <!-- Tag -->
              <div class="w-[13rem]">
                <label class="block text-sm font-medium text-black">Asset Tag</label>
                <input
                  type="text"
                  name={"asset_tags[#{index}][tag]"}
                  value={tag[:tag] || ""}
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
                  placeholder="Enter asset tag"
                />
              </div>

              <!-- Serial -->
              <div class="w-[13rem]">
                <label class="block text-sm font-medium text-black">Asset Serial No</label>
                <input
                  type="text"
                  name={"asset_tags[#{index}][serial_number]"}
                  value={tag[:serial_number] || ""}
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
                  placeholder="Enter serial number"
                />
              </div>

              <!-- Buttons -->
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

        <!-- Submit -->
        <div class="pt-6">
          <button
            type="submit"
            class="inline-flex items-center px-4 py-2 bg-indigo-600 border border-transparent rounded-md font-semibold text-white hover:bg-indigo-700"
            phx-disable-with="Saving..."
          >
            Save Asset
          </button>
        </div>
      </form>
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

    socket =
      allow_upload(socket, :image,
        accept: ~w(.jpg .jpeg .png .gif),
        max_entries: 1,
        max_file_size: 5_000_000,
        auto_upload: true)

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
    asset_tags = parse_asset_tags(all_params)
    asset_params_with_tags = Map.put(asset_params, "asset_tags", asset_tags)

    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        upload_dir = "priv/static/uploads"
        File.mkdir_p!(upload_dir)

        dest = Path.join(upload_dir, Path.basename(path))
        File.cp!(path,dest)

        {:ok, "/uploads/#{Path.basename(dest)}"}
      end)

    asset_params_with_tags =
      case uploaded_files do
        [image_url | _] -> Map.put(asset_params_with_tags, "image", image_url)
        _ -> asset_params_with_tags
      end

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
