defmodule MyKemudahanWeb.Contact do
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

      <!-- Title -->
      <div class="flex justify-center items-center my-8">
        <h1 class="text-black font-bold text-4xl">CONTACT US</h1>
      </div>

      <!-- Main content -->
      <div class="flex flex-col lg:flex-row gap-10 ml-10 mr-10">
        <!-- Left Column: Intro Text + Info + Map -->
        <div class="w-full my-10 px-4">
          <p class="text-black text-base mb-6 max-w-4xl">
            Do you have any question or suggestion regarding the system, do not hesitate to send us a message using the form on the right or alternatively, drop us a visit, call our helpline or send us an email. We will be happy to assist you.
          </p>

          <div class="flex flex-col lg:flex-row gap-8">
            <!-- Contact Details -->
            <div class="lg:w-1/2 flex flex-col justify-center h-full space-y-4">
              <!-- Phone -->
              <div class="flex items-center gap-3">
                <i class="fa fa-phone text-black"></i>
                <p class="text-black text-base">088 - 788 9638</p>
              </div>

              <!-- Email -->
              <div class="flex items-center gap-3">
                <i class="fa fa-envelope text-black"></i>
                <p class="text-black text-base">test@example.com</p>
              </div>

              <!-- Address -->
              <div class="flex items-start gap-3">
                <i class="fa fa-map-marker text-black mt-1"></i>
                <p class="text-black text-base">
                  Lorong 123, Jalan Kg Baru, Putatan, 87006, Sabah, Malaysia
                </p>
              </div>
            </div>

            <!-- Google Map -->
            <div class="lg:w-1/2">
              <iframe
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d15873.865128586203!2d116.06718510373081!3d5.930271972474673!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x323b67857a56e023%3A0x14f4ce9efd879650!2sPutatan%2C%20Sabah!5e0!3m2!1sen!2smy!4v1754979230319!5m2!1sen!2smy"
                class="w-full h-[450px] rounded-md border-0"
                allowfullscreen=""
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade">
              </iframe>
            </div>
          </div>
        </div>

        <!-- Right Column: Form -->
        <div class="lg:w-1/2 bg-slate-700 p-6 rounded-lg space-y-6 mb-10">
          <h2 class="text-white text-2xl font-bold text-center">Send us a message</h2>

          <!-- Full Name -->
          <div>
            <label class="text-white text-sm font-bold block mb-1">Full Name</label>
            <input
              type="text"
              placeholder="Full name"
              class="w-full p-2 rounded-md text-black placeholder-gray-custom border border-white"/>
          </div>

          <!-- Email -->
          <div>
            <label class="text-white text-sm font-bold block mb-1">Email Address</label>
            <input
              type="email"
              placeholder="Email address"
              class="w-full p-2 rounded-md text-black placeholder-gray-custom border border-white"/>
          </div>

          <!-- Message -->
          <div>
            <label class="text-white text-sm font-bold block mb-1">Message</label>
            <textarea
              placeholder="Type your message..."
              rows="4"
              class="w-full p-2 rounded-md text-black placeholder-gray-custom border border-white">
            </textarea>
          </div>

         <!-- Submit Button -->
          <button class="w-full bg-teal-500 text-white font-bold py-2 rounded-md text-center">
            Send Message
          </button>
        </div>
      </div>

      <!-- Footer -->
      <footer class="bg-[#0B132B] text-[#FFF5F5] w-full mt-3 p-4 text-center">
        <p>&copy; 2025 MyWebsite. All rights reserved.</p>
        <nav>
          <a href="/privacy-policy">Privacy Policy</a> |
          <a href="/contact">Contact Us</a>
        </nav>
      </footer>
    """
  end
end
