defmodule MyKemudahanWeb.AssetLive.BulkFormComponent do
  use MyKemudahanWeb, :live_component

  alias MyKemudahan.Assets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold text-black mb-1"><%= @title %></h2>
      <p class="text-sm text-gray-300 mb-6">Use this form to create multiple asset tags for a single asset.</p>

      <form
        id="bulk-asset-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        class="space-y-6"
      >
        <!-- Asset Information -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold text-black">Asset Information</h3>

          <!-- Name -->
          <div>
            <label for="name" class="block text-sm font-medium text-black">Name</label>
            <input
              type="text"
              id="name"
              name="asset[name]"
              value={@form[:name].value}
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              required
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
              required
            />
          </div>

          <!-- Cost, Status, Image Upload -->
          <div class="flex flex-col md:flex-row justify-between gap-4">
            <!-- Cost per unit -->
            <div class="w-full md:w-[12rem]">
              <label class="block text-sm font-medium text-black">Cost per unit</label>
              <input
                type="number"
                name="asset[cost_per_unit]"
                value={@form[:cost_per_unit].value}
                step="any"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
                required
              />
            </div>

            <!-- Status -->
            <div class="w-full md:w-[12rem]">
              <label class="block text-sm font-medium text-black">Status</label>
              <select
                name="asset[status]"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm sm:text-sm"
                required
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
            <div class="w-full md:w-[12rem]">
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
              required
            >
              <%= Phoenix.HTML.Form.options_for_select(@category_options, @form[:category_id].value) %>
            </select>
          </div>
        </div>

        <!-- Asset Tags Information -->
        <div class="space-y-4">
          <h3 class="text-lg font-semibold text-black">Asset Tags Information</h3>

          <!-- Number of Assets -->
          <div>
            <label for="number_of_assets" class="block text-sm font-medium text-black">Number of Assets</label>
            <input
              type="number"
              id="number_of_assets"
              name="bulk[number_of_assets]"
              value={@bulk_form[:number_of_assets].value}
              min="1"
              max="100"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              required
            />
            <p class="mt-1 text-sm text-gray-500">Enter the number of asset tags to create (1-100)</p>
          </div>

          <!-- Tag Prefix -->
          <div>
            <label for="tag_prefix" class="block text-sm font-medium text-black">Tag Prefix</label>
            <input
              type="text"
              id="tag_prefix"
              name="bulk[tag_prefix]"
              value={@bulk_form[:tag_prefix].value}
              placeholder="e.g., LAPTOP"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              required
            />
            <p class="mt-1 text-sm text-gray-500">Prefix for asset tags (e.g., LAPTOP)</p>
          </div>

          <!-- Initial Serial Number -->
          <div>
            <label for="initial_serial" class="block text-sm font-medium text-black">Initial Serial Number</label>
            <input
              type="number"
              id="initial_serial"
              name="bulk[initial_serial]"
              value={@bulk_form[:initial_serial].value}
              min="1"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              required
            />
            <p class="mt-1 text-sm text-gray-500">Starting serial number (subsequent numbers will be incremented by 1). Leading zeros are preserved (e.g., 001, 002, 003)</p>
          </div>

          <!-- Preview -->
          <%= if @preview_tags && length(@preview_tags) > 0 do %>
            <div class="mt-4">
              <h4 class="text-md font-medium text-black mb-2">Preview of Asset Tags:</h4>
              <div class="bg-gray-50 p-3 rounded-md max-h-32 overflow-y-auto">
                <%= for tag <- @preview_tags do %>
                  <div class="text-sm text-gray-700">
                    Tag: <span class="font-mono"><%= tag.tag %></span> |
                    Serial: <span class="font-mono"><%= tag.serial_number %></span>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>

        <!-- Submit -->
        <div class="pt-6">
          <button
            type="submit"
            class="inline-flex items-center px-4 py-2 bg-green-600 border border-transparent rounded-md font-semibold text-white hover:bg-green-700"
            phx-disable-with="Creating Assets..."
          >
            Create Bulk Assets
          </button>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    category_options =
      Assets.list_all_categories()
      |> Enum.map(&{&1.name, &1.id})

    # Initialize form with default values
    asset_changeset = Assets.change_asset(%MyKemudahan.Assets.Asset{})

    # Create a simple form for bulk parameters (use string keys)
    bulk_data = %{"number_of_assets" => "", "tag_prefix" => "", "initial_serial" => ""}
    bulk_form = to_form(bulk_data)

    socket =
      allow_upload(socket, :image,
        accept: ~w(.jpg .jpeg .png .gif),
        max_entries: 1,
        max_file_size: 5_000_000,
        auto_upload: true)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:category_options, category_options)
     |> assign(:form, to_form(asset_changeset))
     |> assign(:bulk_form, bulk_form)
     |> assign(:preview_tags, [])}
  end

  @impl true
  def handle_event("validate", %{"asset" => asset_params, "bulk" => bulk_params}, socket) do
    # Update asset form
    asset_changeset = Assets.change_asset(%MyKemudahan.Assets.Asset{}, asset_params)

    # Update bulk form (use string keys)
    bulk_data = %{"number_of_assets" => "", "tag_prefix" => "", "initial_serial" => ""}
    updated_bulk_data = Map.merge(bulk_data, bulk_params)
    bulk_form = to_form(updated_bulk_data)

    # Generate preview tags if we have valid data
    preview_tags = generate_preview_tags(bulk_params)

    {:noreply,
     socket
     |> assign(:form, to_form(asset_changeset, action: :validate))
     |> assign(:bulk_form, bulk_form)
     |> assign(:preview_tags, preview_tags)}
  end

  def handle_event("save", %{"asset" => asset_params, "bulk" => bulk_params}, socket) do
    # Handle image upload
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
        upload_dir = "priv/static/uploads"
        File.mkdir_p!(upload_dir)

        dest = Path.join(upload_dir, Path.basename(path))
        File.cp!(path, dest)

        {:ok, "/uploads/#{Path.basename(dest)}"}
      end)

    asset_params_with_image =
      case uploaded_files do
        [image_url | _] -> Map.put(asset_params, "image", image_url)
        _ -> asset_params
      end

    save_bulk_asset(socket, asset_params_with_image, bulk_params)
  end

  defp save_bulk_asset(socket, asset_params, bulk_params) do
    case Assets.create_bulk_asset(asset_params, bulk_params) do
      {:ok, _result} ->
        notify_parent({:bulk_saved, :success})

        {:noreply,
         socket
         |> put_flash(:info, "Bulk assets created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp generate_preview_tags(bulk_params) do
    # Safely convert strings to integers, defaulting to 0/1 if empty or invalid
    number_of_assets = try do
      case bulk_params["number_of_assets"] do
        "" -> 0
        nil -> 0
        val -> String.to_integer(val)
      end
    rescue
      ArgumentError -> 0
    end

    tag_prefix = bulk_params["tag_prefix"] || ""

    # Handle initial serial as string to preserve leading zeros
    initial_serial_str = bulk_params["initial_serial"] || "1"
    initial_serial = try do
      case initial_serial_str do
        "" -> 1
        nil -> 1
        val -> String.to_integer(val)
      end
    rescue
      ArgumentError -> 1
    end

    if number_of_assets > 0 and tag_prefix != "" do
      for i <- 0..(number_of_assets - 1) do
        # Calculate serial number preserving leading zeros from original input
        current_serial = initial_serial + i

        # If the original input had leading zeros, preserve them
        serial_display = if String.starts_with?(initial_serial_str, "0") do
          # Preserve the original format with leading zeros
          original_length = String.length(initial_serial_str)
          String.pad_leading(to_string(current_serial), original_length, "0")
        else
          to_string(current_serial)
        end

        %{
          tag: tag_prefix,  # Just the tag prefix, no serial number
          serial_number: serial_display
        }
      end
    else
      []
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
