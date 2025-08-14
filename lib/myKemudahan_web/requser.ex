defmodule MyKemudahanWeb.Requser do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <button class="bg-slate-950 text-white px-4 py-2 rounded-xl">Menu</button>
    </div>

    <div class="bg-[#F9FAFB] mt-3 rounded-xl px-3 py-4 shadow-2xl">
      <p class="text-3xl font-bold mb-4">Asset/Facility Request Form</p>

      <form id="request_form" phx-submit="submit_form">
        <!-- Category Select -->
        <div class="mb-6">
          <label for="category" class="block text-sm font-medium text-gray-700 mb-2">Asset Category:</label>
          <select name="category" id="category" class="w-1/4 p-2 border rounded">
            <option value="">Select Category</option>
            <option value="chair">Chair</option>
            <option value="table">Table</option>
            <option value="canopy">Canopy</option>
            <option value="hall">Hall</option>
          </select>
        </div>

        <!-- Asset Cards -->
        <div class="flex flex-wrap gap-2">
          <%= for _ <- 1..3 do %>
            <div class="w-[13rem] bg-slate-700 rounded-xl shadow-xl p-3 flex flex-col gap-3">
              <!-- Image Placeholder -->
              <div class="w-full h-[10rem] bg-slate-300 rounded-lg flex items-center justify-center">
                <p class="text-sm text-gray-700">Picture Placeholder</p>
              </div>

              <!-- Text Content -->
              <div class="text-white space-y-1">
                <p class="font-bold text-base">Asset Title</p>
                <p class="text-xs text-gray-300">Asset Description</p>
              </div>

              <!-- Input and Button -->
              <div class="flex flex-row items-center gap-2">
                <input
                  type="number"
                  min="1"
                  name="quantity[]"
                  class="w-full px-2 py-1 rounded-md text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-400"
                  placeholder="Qty"
                />
                <button
                  type="button"
                  class="bg-teal-500 hover:bg-teal-600 px-3 py-1 rounded-2xl text-white text-sm transition">
                  Request
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </form>
    </div>

    <div class="bg-[#F9FAFB] mt-3 rounded-xl px-3 py-4 shadow-2xl">
    <p class="text-3xl font-bold mb-4">Requested Asset List</p>

    <form id="request_form" phx-submit="submit_form" class="space-y-4">
    <div class="flex flex-row gap-10">
          <!-- Borrow From Date -->
          <div>
            <label for="borrow_from" class="block text-sm font-medium text-gray-700 mb-1">Borrow From:</label>
            <input
              type="date"
              id="borrow_from"
              name="borrow_from"
              class="w-full max-w-sm p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-teal-400"
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
        ></textarea>
      </div>

      <!-- Submit Button -->
      <div>
        <button
          type="submit"
          class="bg-teal-500 hover:bg-teal-600 text-white font-semibold px-4 py-2 rounded-md transition"
        >
          Confirm Request
        </button>
      </div>
    </form>
    </div>

    """
  end
end
