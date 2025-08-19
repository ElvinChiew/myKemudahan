defmodule MyKemudahanWeb.Dumm do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Assets

  def mount(_params, _session, socket) do
    # Get the latest asset that has an image
    latest_asset =
      Assets.list_assets()
      |> Enum.reverse()
      |> Enum.find(& &1.image)

    {:ok, assign(socket, :image_url, latest_asset && latest_asset.image || "/images/landing-image-webp.webp")}
  end

  def render(assigns) do
    ~H"""
    <div class="px-6 md:px-8 lg:px-0">
      <!-- Hero Section -->
      <section>
        <div class="flex flex-col lg:flex-row items-center justify-between gap-10">
          <!-- Text Content -->
          <div class="w-full lg:w-1/2 flex flex-col items-center justify-center gap-5">
            <img src={~p"/images/MK logo.png"} alt="logo" class="mt-10" />
            <h1 class="text-4xl font-bold text-[#1C2541] mb-4">MyKemudahan</h1>

            <h2 class="text-xl font-bold text-[#1C2541] mb-4">
              Electronic Facility & Asset Requests and Management System
            </h2>

            <p class="text-sm text-[#1C2541] max-w-xl mx-auto lg:mx-0 mb-6">
              Are you in need of a place to hold your events or perhaps in need of equipment for your events?
              Don’t worry, we got you covered. Click the button to make a request.
            </p>
            <div class="inline-block justify justify-center">
              <button class="bg-[#5BC0BE] text-white px-6 py-2 rounded-full font-bold hover:bg-[#3ba7a4] transition justify justify-center">
                Book Now
              </button>
            </div>
          </div>
          <!-- Dynamic Image -->
          <div class="w-full lg:w-1/2">
            <img
              src={@image_url}
              alt="landing image"
              class="shadow-lg w-full h-[20rem] md:h-[42rem] object-cover"
            />
          </div>
        </div>
      </section>
    </div>
    """
  end
end
