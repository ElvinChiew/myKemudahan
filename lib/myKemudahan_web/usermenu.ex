defmodule MyKemudahanWeb.Usermenu do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <!-- Navbar -->
    <nav class="flex justify-end space-x-10 px-20 py-6 bg-[#0B132B] text-[#FFF5F5] w-full">
      <a href="#" class="text-lg">Home</a> <a href="#" class="text-lg">About</a>
      <a href="#" class="text-lg">Contact Us</a> <a href="#" class="text-lg">Login/Register</a>
    </nav>
    <!-- Centered cards container -->
    <div class="h-screen flex items-center justify-center">
      <div class="flex flex-row gap-20">
        <div class="w-[400px] rounded-xl bg-slate-700 p-10 text-sm/7 text-gray-700 dark:bg-gray-950 dark:text-gray-300">
          <p class="text-xl font-bold text-center text-white">Asset Borrowing Request</p>
          
          <p class="text-white">Make asset borrowing request quickly and easily, hassle free.</p>
          
          <div class="flex justify-end mt-5">
            <button class="bg-teal-500 rounded-2xl px-3 py-1 text-white mt-5">Request</button>
          </div>
        </div>
        
        <div class="w-[400px] rounded-xl bg-slate-700 p-10 text-sm/7 text-gray-700 dark:bg-gray-950 dark:text-gray-300">
          <p class="text-xl font-bold text-center text-white">Check Request Status</p>
          
          <p class="text-white mt-2">
            Check the status of your requests. Have a change of mind? You can edit your request here.
          </p>
          
          <div class="flex justify-end mt-5">
            <button class="bg-teal-500 rounded-2xl px-3 py-1 text-white">Check Status</button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
