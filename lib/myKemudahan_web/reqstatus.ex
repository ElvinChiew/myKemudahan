defmodule MyKemudahanWeb.Reqstatus do
  #alias GenLSP.Structures.SemanticTokensClientCapabilities
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <button class="bg-slate-950 text-white px-4 py-2 rounded-xl">Menu</button>
    </div>

    <div class="flex justify-center">
    <p class="text-3xl font-bold">List of Requests</p>
    </div>

    <div class="mb-6">
    <label for="req-group" class="block text-sm font-medium text-gray-700 mb-2">Filter by</label>
    <select name="req-category" id="req-category" class="w-1/4 p-2 border rounded">
      <option value="">Select Filter</option>
      <option value="chair">Date</option>
      <option value="table">Status</option>
    </select>
    </div>

    <div class="bg-[#F9FAFB] mt-3 rounded-xl px-3 py-4 shadow-2xl">


      <div class="flex flex-rows justify-between">
        <div class="status-color">
          <span class="inline-block px-3 py-1 text-sm font-semibold text-white bg-blue-700 rounded-full">
            Sent
          </span>
          <span class="inline-block px-3 py-1 text-sm font-semibold text-white bg-green-700 rounded-full">
            Approved
          </span>
          <span class="inline-block px-3 py-1 text-sm font-semibold text-white bg-yellow-400 rounded-full">
            Pending
          </span>
          <span class="inline-block px-3 py-1 text-sm font-semibold text-white bg-red-700 rounded-full">
            Rejected
          </span>
        </div>
        <div class="button-calcel-detail">
          <button class="bg-slate-950 text-white px-3 rounded-xl">
            Cancel
          </button>
          <button class="bg-slate-950 text-white px-3 rounded-xl">
            Detail
          </button>
        </div>

      </div>

      <div class="flex flex-rows justify-between">
        <p class="text-xl font-bold mb-4">Tujuan 1 balablabala</p>
        <p class="text-xl font-bold mb-4">12/10/2024 - 15/12/2024</p>
      </div>
    </div><!-- End 1 card status -->




    """
  end
end
