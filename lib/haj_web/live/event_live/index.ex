defmodule HajWeb.EventLive.Index do
  use HajWeb, :live_view

  alias Haj.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, events: list_events())}
  end

  @impl true
  def handle_info({Events, [:registration, _], _}, socket) do
    {:noreply, assign(socket, events: list_events())}
  end

  defp list_events do
    # Todo: maybe fetch in one query
    Events.list_events()
    |> Enum.map(fn event ->
      ticked_sold = Events.tickets_sold(event.id)
      Map.put(event, :availible, event.ticket_limit - ticked_sold)
    end)
  end

  @impl true
  def handle_event("register", %{"id" => id}, socket) do
    case Events.create_event_registration(%{
           "user_id" => socket.assigns.current_user.id,
           "ticket_type_id" => id
         }) do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Purchased")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Error")}
    end
  end

  defp event_card(assigns) do
    ~H"""
    <.link navigate={~p"/events/#{@event}"}>
      <div class="group relative mx-0 flex h-64 flex-col overflow-hidden rounded-xl border bg-white duration-150 hover:bg-gray-50">
        <div class="h-2/3 overflow-hidden">
          <img
            :if={@event.image}
            src={@event.image}
            alt={"Picture of #{@event.name}"}
            class="tmt relative right-0 left-0 h-full w-full object-cover p-0"
          />
          <div
            :if={!@event.image}
            class="bg-size-125 bg-pos-0 from-burgandy-400 to-burgandy-800 inset-0 h-full w-full bg-gradient-to-br duration-300 ease-in-out group-hover:bg-pos-100"
          />
        </div>

        <div class="flex w-full flex-row items-center justify-between bg-inherit p-4">
          <div class="flex flex-col">
            <div class="text-xl font-bold"><%= @event.name %></div>
            <div class="text-gray-500">
              <%= Calendar.strftime(@event.event_date, "%A %d %B %H:%M",
                month_names: &swe_month_name/1,
                day_of_week_names: &swe_day_name/1
              ) %>
            </div>
          </div>
        </div>
      </div>
    </.link>
    """
  end
end
