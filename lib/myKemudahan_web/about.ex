defmodule MyKemudahanWeb.About do
  use MyKemudahanWeb, :live_view

  def render(assigns) do
    ~H"""
    <!-- Navbar -->
    <nav class="flex justify-end space-x-10 px-20 py-6 bg-[#0B132B] text-[#FFF5F5] w-full">
      <a href="#" class="text-lg">Home</a>
      <a href="#" class="text-lg">About</a>
      <a href="#" class="text-lg">Contact Us</a>
      <a href="#" class="text-lg">Login/Register</a>
    </nav>

    <div class="px-6 md:px-8 lg:px-0">
      <!-- Hero Section -->
      <section>
        <div class="flex flex-col lg:flex-row items-center justify-between gap-10">

          <!-- Text Content -->
          <div class="w-full lg:w-1/2 flex flex-col items-center justify-center text-center gap-5">
            <h1 class="text-4xl font-bold text-[#1C2541]">ABOUT US</h1>
            <p class="text-md text-[#1C2541] max-w-xl mx-auto lg:mx-0 mb-6">
              MyKemudahan is an electronic Facility & Assets Requests and Managements designed to simplify the way you request and manage assets and facilities. Whether you're booking assets such as tables and chairs, renting fields and sports courts, or managing multiple requests, MyKemudahan makes the process faster, more transparent, and hassle-free
            </p>
            <p class="text-md text-[#1C2541] max-w-xl mx-auto lg:mx-0 mb-6">
              Built with users in mind, the system empowers both everyday users and administrators with easy access, real-time tracking, and a streamlined approval flow — all in one place. No more manual forms, back-and-forth emails, or uncertainty.
            </p>
            <p class="text-md text-[#1C2541] max-w-xl mx-auto lg:mx-0 mb-6">
              We believe that efficiency starts with simplicity. MyKemudahan exists to save your time, improve communication, and ensure smooth coordination across departments.
            </p>
          </div>

          <!-- Image -->
          <div class="w-full h-[650px] overflow-hidden relative lg:w-1/2">
            <img src={~p"/images/about-image-webp.webp"} alt="about image"
                 class="absolute bottom-[-150px] shadow-lg ml-auto blur-sm w-full h-auto" />

            <!-- Glass Cards Container -->
            <div class="absolute top-10 left-10 flex flex-col gap-y-6">

              <!-- Card 1 -->
              <div class="flex items-start gap-4">
                <div class="w-24 h-24 rounded-full bg-white/10 backdrop-blur-md border border-white/30 p-4 shadow-lg mt-2 flex items-center justify-center">
                  <i class="fa fa-rocket text-[60px] text-[#0B132B]" aria-hidden="true"></i>
                </div>
                <div class="bg-white/10 backdrop-blur-md border border-white/30 p-4 rounded-xl shadow-lg max-w-sm">
                  <h2 class="text-black text-xl font-semibold mb-2">Fast and efficient</h2>
                  <p class="text-black/80 text-sm">Book and manage requests easily. MyKemudahan gets you what you need, fast and hassle-free.</p>
                </div>
              </div>

              <!-- Card 2 -->
              <div class="flex items-start gap-4">
                <div class="w-24 h-24 rounded-full bg-white/10 backdrop-blur-md border border-white/30 p-4 shadow-lg mt-2 flex items-center justify-center">
                  <i class="fa fa-clock text-[60px] text-[#0B132B]" aria-hidden="true"></i>
                </div>
                <div class="bg-white/10 backdrop-blur-md border border-white/30 p-4 rounded-xl shadow-lg max-w-sm">
                  <h2 class="text-black text-xl font-semibold mb-2">Saves time</h2>
                  <p class="text-black/80 text-sm">No more paperwork or long emails. MyKemudahan saves time so you can focus on what matters.</p>
                </div>
              </div>

              <!-- Card 3 -->
              <div class="flex items-start gap-4">
                <div class="w-24 h-24 rounded-full bg-white/10 backdrop-blur-md border border-white/30 p-4 shadow-lg mt-2 flex items-center justify-center">
                  <i class="fa fa-search text-[60px] text-[#0B132B]" aria-hidden="true"></i>
                </div>
                <div class="bg-white/10 backdrop-blur-md border border-white/30 p-4 rounded-xl shadow-lg max-w-sm">
                  <h2 class="text-black text-xl font-semibold mb-2">Transparent process</h2>
                  <p class="text-black/80 text-sm">Stay updated every step of the way — from request to approval, in real time.</p>
                </div>
              </div>

              <!-- Card 4 -->
              <div class="flex items-start gap-4">
                <div class="w-24 h-24 rounded-full bg-white/10 backdrop-blur-md border border-white/30 p-4 shadow-lg mt-2 flex items-center justify-center">
                  <i class="fa fa-cubes text-[60px] text-[#0B132B]" aria-hidden="true"></i>
                </div>
                <div class="bg-white/10 backdrop-blur-md border border-white/30 p-4 rounded-xl shadow-lg max-w-sm">
                  <h2 class="text-black text-xl font-semibold mb-2">Easy access to assets and facility</h2>
                  <p class="text-black/80 text-sm">Find and book chairs, tables, halls, and more — all in one place, anytime.</p>
                </div>
              </div>

            </div>
          </div>

        </div>
      </section>

      <!-- Footer -->
      <footer class="bg-[#0B132B] text-[#FFF5F5] w-full p-4 text-center">
        <p>&copy; 2025 MyWebsite. All rights reserved.</p>
        <nav>
          <a href="/privacy-policy">Privacy Policy</a> |
          <a href="/contact">Contact Us</a>
        </nav>
      </footer>
    </div>
    """
  end
end
