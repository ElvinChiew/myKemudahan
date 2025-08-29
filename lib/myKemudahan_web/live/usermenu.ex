defmodule MyKemudahanWeb.Usermenu do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
        <!-- Wrapper with relative positioning to allow layering -->
        <div class="relative h-screen flex items-center justify-center overflow-hidden">

        <!-- Blurred Background Image Layer -->
        <div class="absolute inset-0 bg-cover bg-center bg-no-repeat blur-lg scale-110"
            style="background-image: url('/images/landing-image-webp.webp')">
        </div>

        <!-- Content Layer -->
        <div class="relative z-10 flex flex-col md:flex-row gap-6 md:gap-20 p-4">
          <!-- Card 1 -->
          <div class="w-full max-w-md rounded-xl bg-slate-700 p-8 text-sm/7 text-gray-700 dark:bg-gray-950 dark:text-gray-300 shadow-lg">
            <p class="text-xl font-bold text-center text-white">Asset Borrowing Request</p>
            <p class="text-white mt-2">Need equipment or tools? Submit your request in seconds. No fuss, no delays, just smooth and hassle-free borrowing.</p>
            <div class="flex justify-end mt-5">
              <button phx-click="go_to_requser" class="bg-teal-500 rounded-2xl px-4 py-2 text-white hover:bg-teal-600">Request</button>
            </div>
          </div>

          <!-- Card 2 -->
          <div class="w-full max-w-md rounded-xl bg-slate-700 p-8 text-sm/7 text-gray-700 dark:bg-gray-950 dark:text-gray-300 shadow-lg">
            <p class="text-xl font-bold text-center text-white">Check Request Status</p>
            <p class="text-white mt-2">Check the status of your requests. Have a change of mind? You can edit your request here.</p>
            <div class="flex justify-end mt-5">
              <button phx-click="to_request_status" class="bg-teal-500 rounded-2xl px-4 py-2 text-white">Check Status</button>
            </div>
          </div>
        </div>
        </div>
    """
    end

  def handle_event("go_to_requser", _params, socket) do
    {:noreply, push_navigate(socket, to: "/requser")}
  end

  def handle_event("to_request_status", _params, socket) do
    {:noreply, push_navigate(socket, to: "/reqstatus")}
  end
end
