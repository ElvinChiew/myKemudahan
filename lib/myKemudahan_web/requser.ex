defmodule MyKemudahanWeb.Requser do
alias MyKemudahan.Accounts
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Assets
  alias MyKemudahan.Accounts

  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}


  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    all_assets = Assets.list_assets() |> MyKemudahan.Repo.preload(:category)
    categories = Assets.list_all_categories()

    socket =
      assign(socket,
      assets: all_assets,
      categories: categories,
      selected_category: nil,
      filtered_assets: all_assets,
      requested_items: [],
      total_cost: Decimal.new("0"),
      discount_amount: Decimal.new("0"),
      final_cost: Decimal.new("0"),
      current_page: 1,
      page_size: 12,
      user_id: user.id,
      status: "sent"
    )

    {:ok, socket}
  end

  def handle_event("filter_by_category", %{"category" => category_id}, socket) do
    filtered_assets = if category_id == "" do
      socket.assigns.assets
    else
      socket.assigns.assets |> Enum.filter(&(&1.category_id == String.to_integer(category_id)))
    end

    {:noreply, assign(socket, filtered_assets: filtered_assets, selected_category: category_id, current_page: 1)}
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
        user_id: socket.assigns.user_id,
        status: "sent",
        discount_amount: Decimal.new("0"),
        final_cost: socket.assigns.total_cost
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

  def handle_event("change_page", %{"page" => page_str}, socket) do
    case Integer.parse(page_str) do
      {page, ""} when page > 0 ->
        {:noreply, assign(socket, current_page: page)}
      _ ->
        {:noreply, socket}
    end
  end

  defp recalc_total(items) do
    Enum.reduce(items, Decimal.new("0"), fn item, acc ->
      item_total = Decimal.mult(item.cost_per_unit, Decimal.new(item.quantity))
      Decimal.add(acc, item_total)
    end)
  end

  defp paginated_assets(filtered_assets, current_page, page_size) do
    filtered_assets
    |> Enum.chunk_every(page_size)
    |> Enum.at(current_page - 1, [])
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
      <div class="max-w-7xl mx-auto">
        <!-- Header with back button -->
        <div class="flex items-center justify-between mb-8">
          <button
            phx-click="go_to_menu"
            class="inline-flex items-center text-sm font-medium text-teal-600 hover:text-teal-800 transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back to Menu
          </button>
          <h1 class="text-3xl font-bold text-gray-900">Asset Request Form</h1>
          <div class="w-24"></div> <!-- Spacer for balance -->
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Left Column - Asset Selection -->
          <div class="lg:col-span-2">
            <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
              <h2 class="text-xl font-semibold text-gray-800 mb-4">Select Assets</h2>

              <!-- Category Filter -->
              <div class="mb-6">
                <label for="category" class="block text-sm font-medium text-gray-700 mb-2">Filter by Category:</label>
                <form phx-change="filter_by_category">
                  <select
                    name="category"
                    id="category"
                    class="w-full md:w-64 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                  >
                    <option value="">All Categories</option>
                    <%= for category <- @categories do %>
                      <option value={category.id} selected={@selected_category == Integer.to_string(category.id)}>
                        <%= category.name %>
                      </option>
                    <% end %>
                  </select>
                </form>
              </div>

              <!-- Asset Grid -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <%= for asset <- paginated_assets(@filtered_assets, @current_page, @page_size) do %>
                  <div class="bg-gray-50 rounded-lg border border-gray-200 p-4 hover:shadow-md transition-shadow">
                    <!-- Asset Image -->
                    <div class="w-full h-40 bg-gray-200 rounded-md overflow-hidden mb-3 flex items-center justify-center">
                      <%= if asset.image && asset.image != "" do %>
                        <img src={asset.image} alt={asset.name} class="w-full h-full object-cover" />
                      <% else %>
                        <div class="text-gray-400">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                          </svg>
                        </div>
                      <% end %>
                    </div>

                    <!-- Asset Details -->
                    <div class="mb-3">
                      <h3 class="font-medium text-gray-900 text-lg mb-1"><%= asset.name %></h3>
                      <p class="text-sm text-gray-600 mb-2 line-clamp-2"><%= asset.description %></p>
                      <div class="flex justify-between items-center">
                        <span class="text-sm text-gray-500">RM<%= Decimal.to_string(asset.cost_per_unit, :normal) %></span>
                        <span class={"text-xs px-2 py-1 rounded-full #{if asset.status == "available", do: "bg-green-100 text-green-800", else: "bg-red-100 text-red-800"}"}>
                          <%= asset.status %>
                        </span>
                      </div>
                    </div>

                    <!-- Request Form -->
                    <form phx-submit="add_item" class="flex items-center gap-2">
                      <input type="hidden" name="asset_id" value={asset.id} />
                      <input
                        type="number"
                        min="1"
                        name="quantity"
                        class="flex-1 p-2 border border-gray-300 rounded-md text-sm focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                        placeholder="Quantity"
                        required
                      />
                      <button
                        type="submit"
                        class="bg-teal-600 hover:bg-teal-700 text-white p-2 rounded-md transition-colors flex items-center justify-center"
                        title="Add to request"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                      </button>
                    </form>
                  </div>
                <% end %>
              </div>

              <!-- Pagination -->
              <% total_pages = max(Float.ceil(length(@filtered_assets) / @page_size), 1) %>
              <% page_numbers = MyKemudahanWeb.PaginationHelpers.pagination_range(@current_page, total_pages) %>

              <%= if total_pages > 1 do %>
                <div class="flex justify-center mt-8">
                  <nav class="flex items-center space-x-1">
                    <!-- Previous Button -->
                    <button
                      phx-click="change_page"
                      phx-value-page={@current_page - 1}
                      disabled={@current_page == 1}
                      class={"p-2 rounded-md #{if @current_page == 1, do: "text-gray-400 cursor-not-allowed", else: "text-gray-700 hover:bg-gray-100"}"}
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                      </svg>
                    </button>

                    <!-- Page Numbers -->
                    <%= for page <- page_numbers do %>
                      <%= if page == "..." do %>
                        <span class="px-3 py-1 text-gray-500">...</span>
                      <% else %>
                        <button
                          phx-click="change_page"
                          phx-value-page={page}
                          class={"px-3 py-1 rounded-md text-sm font-medium #{if page == @current_page, do: "bg-teal-600 text-white", else: "text-gray-700 hover:bg-gray-100"}"}
                        >
                          <%= page %>
                        </button>
                      <% end %>
                    <% end %>

                    <!-- Next Button -->
                    <button
                      phx-click="change_page"
                      phx-value-page={@current_page + 1}
                      disabled={@current_page == total_pages}
                      class={"p-2 rounded-md #{if @current_page == total_pages, do: "text-gray-400 cursor-not-allowed", else: "text-gray-700 hover:bg-gray-100"}"}
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                      </svg>
                    </button>
                  </nav>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Right Column - Request Summary -->
          <div class="lg:col-span-1">
            <div class="bg-white rounded-xl shadow-sm p-6 sticky top-6">
              <h2 class="text-xl font-semibold text-gray-800 mb-4">Request Summary</h2>

              <!-- Request Details Form -->
              <form id="confirm_form" phx-submit="submit_form" class="space-y-4 mb-6">
                <div>
                  <label for="borrow_from" class="block text-sm font-medium text-gray-700 mb-1">Borrow From:</label>
                  <input
                    type="date"
                    id="borrow_from"
                    name="borrow_from"
                    class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                    required
                  />
                </div>

                <div>
                  <label for="borrow_to" class="block text-sm font-medium text-gray-700 mb-1">Borrow To:</label>
                  <input
                    type="date"
                    id="borrow_to"
                    name="borrow_to"
                    class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                    required
                  />
                </div>

                <div>
                  <label for="purpose" class="block text-sm font-medium text-gray-700 mb-1">Purpose:</label>
                  <textarea
                    id="purpose"
                    name="purpose"
                    rows="4"
                    class="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                    placeholder="Please describe the purpose of your request..."
                    required
                  ></textarea>
                </div>
              </form>

              <!-- Requested Items Table -->
                <div class="mb-6">
                <h3 class="font-medium text-gray-700 mb-3">Requested Items</h3>

                <%= if @requested_items != [] do %>
                  <!-- Add scrollable container with fixed height -->
                  <div class="max-h-64 overflow-y-auto border border-gray-200 rounded-lg">
                    <div class="space-y-3 p-2">
                      <%= for item <- @requested_items do %>
                        <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                          <div class="flex-1">
                            <p class="font-medium text-gray-900"><%= item.name %></p>
                            <div class="flex items-center mt-1">
                              <form phx-submit="update_item" class="flex items-center">
                                <input type="hidden" name="_id" value={item.id} />
                                <input
                                  type="number"
                                  min="1"
                                  name="quantity"
                                  value={item.quantity}
                                  class="w-16 p-1 border border-gray-300 rounded text-sm text-center focus:ring-1 focus:ring-teal-500 focus:border-teal-500"
                                  required
                                />
                                <button
                                  type="submit"
                                  class="ml-2 text-teal-600 hover:text-teal-800 transition-colors"
                                  title="Update quantity"
                                >
                                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                                  </svg>
                                </button>
                              </form>
                              <span class="text-sm text-gray-600 ml-3">
                                × RM<%= Decimal.to_string(item.cost_per_unit, :normal) %>
                              </span>
                            </div>
                          </div>

                          <div class="flex items-center space-x-2">
                            <span class="text-sm font-medium text-gray-900">
                              RM<%= Decimal.mult(item.cost_per_unit, Decimal.new(item.quantity)) |> Decimal.to_string(:normal) %>
                            </span>
                            <button
                              phx-click="remove_item"
                              phx-value-id={item.id}
                              class="text-red-500 hover:text-red-700 transition-colors"
                              title="Remove item"
                            >
                              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                              </svg>
                            </button>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  </div>

                  <!-- Total Cost (moved outside the scrollable area) -->
                  <div class="mt-4 pt-3 border-t border-gray-200">
                    <div class="flex justify-between items-center font-medium text-gray-900">
                      <span>Total Cost:</span>
                      <span>RM<%= Decimal.to_string(@total_cost, :normal) %></span>
                    </div>
                  </div>
                <% else %>
                  <div class="text-center py-8 text-gray-500">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto text-gray-300 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                    </svg>
                    <p>No items added yet</p>
                  </div>
                <% end %>
              </div>

              <!-- Submit Button -->
              <button
                type="submit"
                form="confirm_form"
                disabled={@requested_items == []}
                class={"w-full py-3 px-4 rounded-lg font-medium transition-colors #{if @requested_items == [], do: "bg-gray-300 text-gray-500 cursor-not-allowed", else: "bg-teal-600 hover:bg-teal-700 text-white"}"}
              >
                Submit Request
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
