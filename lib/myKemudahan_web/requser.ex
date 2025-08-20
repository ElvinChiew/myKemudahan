defmodule MyKemudahanWeb.Requser do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Assets

  def mount(_params, _session, socket) do
    assets = Assets.list_assets() |> MyKemudahan.Repo.preload(:category)
    categories = Assets.list_all_categories()

    socket = assign(socket,
      assets: assets,
      categories: categories,
      selected_category: nil,
      filtered_assets: assets,
      requested_items: [],
      total_cost: Decimal.new("0")
    )

    {:ok, socket}
  end

  def handle_event("filter_by_category", %{"category" => category_id}, socket) do
    filtered_assets = if category_id == "" do
      socket.assigns.assets
    else
      socket.assigns.assets |> Enum.filter(&(&1.category_id == String.to_integer(category_id)))
    end

    {:noreply, assign(socket, filtered_assets: filtered_assets, selected_category: category_id)}
  end

  def handle_event("submit_form", %{
    "borrow_from" => borrow_from,
    "borrow_to" => borrow_to,
    "purpose" => purpose
  }, socket) do
    with {:ok, parsed_borrow_from} <- Date.from_iso8601(borrow_from),
         {:ok, parsed_borrow_to} <- Date.from_iso8601(borrow_to) do

      attrs = %{
        borrow_from: parsed_borrow_from,
        borrow_to: parsed_borrow_to,
        purpose: purpose,
        total_cost: socket.assigns.total_cost,
      }

      case MyKemudahan.Requests.create_request_with_items(attrs, socket.assigns.requested_items) do
        {:ok, _result} ->
          socket =
            socket
            |> put_flash(:info, "Request submitted successfully!")
            |> assign(requested_items: [], total_cost: Decimal.new("0"))

          {:noreply, socket}

        {:error, _failed_operation, _failed_value, _changes_so_far} ->
          socket =  put_flash(socket, :error, "Something went wrong. Please try again.")
          {:noreply, socket}
      end
    else
      _ ->
          socket = put_flash(socket, :error, "Invalid date format. Please check your dates.")
          {:noreply, socket}
    end
  end

  def handle_event("add_item", %{"asset_id" => asset_id_str, "quantity" => quantity_str}, socket) do
    with {asset_id, ""} <- Integer.parse(asset_id_str),
         {quantity, ""} <- Integer.parse(quantity_str),
         true <- quantity > 0,
         asset when not is_nil(asset) <- Enum.find(socket.assigns.assets, &(&1.id == asset_id)) do
      existing_items = socket.assigns.requested_items
      {existing_item, others} =
        existing_items
        |> Enum.split_with(&(&1.id == asset_id))

      new_quantity =
        case existing_item do
          [%{quantity: q}] -> q + quantity
          _ -> quantity
        end

      updated_item = %{
        id: asset.id,
        name: asset.name,
        cost_per_unit: asset.cost_per_unit,
        quantity: new_quantity
      }

      new_items = [updated_item | Enum.reject(others, &is_nil/1)]
      new_total = recalc_total(new_items)
      {:noreply, assign(socket, requested_items: new_items, total_cost: new_total)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("update_item", %{"_id" => id_str, "quantity" => quantity_str}, socket) do
    with {id, ""} <- Integer.parse(id_str),
         {quantity, ""} <- Integer.parse(quantity_str),
         true <- quantity > 0 do
      updated =
        Enum.map(socket.assigns.requested_items, fn item ->
          if item.id == id, do: %{item | quantity: quantity}, else: item
        end)

      {:noreply, assign(socket, requested_items: updated, total_cost: recalc_total(updated))}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("remove_item", %{"id" => id_str}, socket) do
    case Integer.parse(id_str) do
      {id, ""} ->
        remaining = Enum.reject(socket.assigns.requested_items, &(&1.id == id))
        {:noreply, assign(socket, requested_items: remaining, total_cost: recalc_total(remaining))}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("go_to_menu", _params, socket) do
    {:noreply, push_navigate(socket, to: "/usermenu")}
  end

  defp recalc_total(items) do
    Enum.reduce(items, Decimal.new("0"), fn item, acc ->
      item_total = Decimal.mult(item.cost_per_unit, Decimal.new(item.quantity))
      Decimal.add(acc, item_total)
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="w-full mt-10">
      <button phx-click="go_to_menu" class="bg-slate-950 text-white px-4 py-2 rounded-xl">Menu</button>
    </div>

    <div class="bg-[#F9FAFB] mt-3 rounded-xl px-3 py-4 shadow-2xl">
      <p class="text-3xl font-bold mb-4">Asset/Facility Request Form</p>

      <div>
        <!-- Category Select -->
        <div class="mb-6">
          <label for="category" class="block text-sm font-medium text-gray-700 mb-2">Asset Category:</label>
          <form phx-change="filter_by_category">
          <select
            name="category"
            id="category"
            class="w-1/4 p-2 border rounded">
            <option value="">All Categories</option>
            <%= for category <- @categories do %>
              <option value={category.id} selected={@selected_category == Integer.to_string(category.id)}>
                <%= category.name %>
              </option>
            <% end %>
          </select>
          </form>
        </div>

        <!-- Asset Cards -->
        <div class="flex flex-wrap gap-2">
          <%= for asset <- @filtered_assets do %>
            <div class="w-[13rem] bg-slate-700 rounded-xl shadow-xl p-3 flex flex-col gap-3">
              <!-- Image Placeholder -->
              <div class="w-full h-[10rem] bg-slate-300 rounded-lg flex items-center justify-center">
                <%= if asset.image && asset.image != "" do %>
                  <img src={asset.image} alt={asset.name} class="w-full h-full object-cover rounded-lg" />
                <% else %>
                  <p class="text-sm text-gray-700">No Image</p>
                <% end %>
              </div>

              <!-- Text Content -->
              <div class="text-white space-y-1">
                <p class="font-bold text-base"><%= asset.name %></p>
                <p class="text-xs text-gray-300"><%= asset.description %></p>
                <p class="text-xs text-gray-300">Status: <%= asset.status %></p>
                <p class="text-xs text-gray-300">Cost: RM<%= Decimal.to_string(asset.cost_per_unit, :normal) %></p>
                <%= if asset.category do %>
                  <p class="text-xs text-gray-300">Category: <%= asset.category.name %></p>
                <% end %>
              </div>

              <!-- Input and Button -->
              <form phx-submit="add_item" class="flex flex-row items-center gap-2">
                <input type="hidden" name="asset_id" value={asset.id} />
                <input
                  type="number"
                  min="1"
                  name="quantity"
                  class="w-full px-2 py-1 rounded-md text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-400"
                  placeholder="Qty"
                  required
                />
                <button
                  type="submit"
                  class="bg-teal-500 hover:bg-teal-600 px-3 py-1 rounded-2xl text-white text-sm transition">
                  Request
                </button>
              </form>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <div class="bg-[#F9FAFB] mt-3 rounded-xl px-3 py-4 shadow-2xl">
    <p class="text-3xl font-bold mb-4">Requested Asset List</p>

      <!-- Submit Button -->
      <form id="confirm_form" phx-submit="submit_form">
        <div class="flex flex-row gap-10">
          <!-- Borrow From Date -->
          <div>
            <label for="borrow_from" class="block text-sm font-medium text-gray-700 mb-1">Borrow From:</label>
            <input
              type="date"
              id="borrow_from"
              name="borrow_from"
              class="w-full max-w-sm p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-teal-400"
              required
            />
          </div>

          <!-- Borrow To Date -->
          <div>
            <label for="borrow_to" class="block text-sm font-medium text-gray-700 mb-1">Borrow To:</label>
            <input
              type="date"
              id="borrow_to"
              name="borrow_to"
              class="w-full max-w-sm p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-teal-400"
              required
            />
          </div>
        </div>

        <!-- Purpose Textarea -->
        <div>
          <label for="purpose" class="block text-sm font-medium text-gray-700 mb-1">Please state the purpose of the request:</label>
          <textarea
            id="purpose"
            name="purpose"
            rows="4"
            class="w-full max-w-lg p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-teal-400"
            placeholder="Type your reason here..."
            required
          ></textarea>
                </div>
      </form>

      <div class="overflow-x-auto rounded-lg shadow border border-gray-200 bg-white">
        <table class="min-w-full text-sm text-left">
          <thead class="bg-teal-500 text-white uppercase text-xs">
            <tr>
              <th class="px-4 py-3">Asset</th>
              <th class="px-4 py-3">Quantity</th>
              <th class="px-4 py-3">Charge (RM)</th>
              <th class="px-4 py-3">Actions</th>
            </tr>
          </thead>

          <tbody class="divide-y divide-gray-200">
            <%= for item <- @requested_items do %>
              <tr class="hover:bg-gray-50 transition-colors">
                <td class="px-4 py-3 font-medium text-gray-900"><%= item.name %></td>

                <td class="px-4 py-3">
                  <form phx-submit="update_item" class="flex items-center gap-2">
                    <input type="hidden" name="_id" value={item.id} />
                    <input
                      type="number"
                      min="1"
                      name="quantity"
                      value={item.quantity}
                      class="w-20 px-2 py-1 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                      required
                    />
                    <button
                      type="submit"
                      title="Update quantity"
                      class="flex items-center gap-1 px-2 py-1 text-xs bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                      </svg>
                      Update
                    </button>
                  </form>
                </td>

                <td class="px-4 py-3 text-gray-700">
                  RM<%= Decimal.mult(item.cost_per_unit, Decimal.new(item.quantity)) |> Decimal.to_string(:normal) %>
                </td>

                <td class="px-4 py-3">
                  <button
                    type="button"
                    phx-click="remove_item"
                    phx-value-id={item.id}
                    title="Remove item"
                    class="flex items-center gap-1 px-2 py-1 text-xs bg-red-600 text-white rounded-md hover:bg-red-700 transition"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                    Remove
                  </button>
                </td>
              </tr>
            <% end %>

            <%= if @requested_items == [] do %>
              <tr>
                <td colspan="4" class="px-4 py-6 text-center text-gray-500 italic">
                  No items requested yet.
                </td>
              </tr>
            <% end %>
          </tbody>

          <tfoot class="bg-gray-50 border-t border-gray-200 font-semibold">
            <tr>
              <td colspan="2" class="px-4 py-3">Total</td>
              <td class="px-4 py-3 text-gray-900">RM<%= Decimal.to_string(@total_cost, :normal) %></td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Submit Button -->
      <div>
        <button
          type="submit"
          form="confirm_form"
          class="bg-teal-500 hover:bg-teal-600 text-white font-semibold px-4 py-2 rounded-md transition"
        >
          Confirm Request
        </button>
      </div>
    </div>
    """
  end
end
