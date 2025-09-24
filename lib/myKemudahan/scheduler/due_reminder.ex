defmodule MyKemudahan.Scheduler.DueReminder do
  use GenServer

  require Logger

  alias MyKemudahan.Requests
  alias MyKemudahan.Mailer
  alias MyKemudahan.Mailer.RequestEmail

  @tick_interval_ms :timer.hours(24)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_next_run(:immediate)
    {:ok, state}
  end

  @impl true
  def handle_info(:run, state) do
    run_once()
    schedule_next_run(:daily)
    {:noreply, state}
  end

  defp schedule_next_run(:immediate) do
    Process.send_after(self(), :run, 5_000)
  end

  defp schedule_next_run(:daily) do
    # Schedule at the next 09:00 Kuala Lumpur time (+08:00), which is 01:00 UTC
    now = DateTime.utc_now()
    today_target_utc = DateTime.new!(Date.utc_today(), ~T[01:00:00], "Etc/UTC")

    next_run =
      if DateTime.compare(now, today_target_utc) == :lt do
        today_target_utc
      else
        DateTime.add(today_target_utc, 86_400, :second)
      end

    delay_ms = max(1, DateTime.diff(next_run, now, :millisecond))
    Process.send_after(self(), :run, delay_ms)
  end

  def run_once do
    requests = Requests.list_requests_due_tomorrow()

    Enum.each(requests, fn request ->
      try do
        RequestEmail.due_soon_email(request)
        |> Mailer.deliver()
      rescue
        exception ->
          Logger.error("Failed to send due reminder for request #{request.id}: #{inspect(exception)}")
      end
    end)
  end
end
