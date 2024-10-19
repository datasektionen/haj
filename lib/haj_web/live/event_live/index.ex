defmodule HajWeb.EventLive.Index do
  use HajWeb, :live_view

  alias Haj.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"date" => date}, _url, socket) do
    date = Date.from_iso8601!(date)

    {:noreply,
     assign(socket,
       selected_date: date,
       events: events_in_month(date)
     )}
  end

  def handle_params(_params, _url, socket) do
    date = Date.utc_today()

    {:noreply,
     assign(socket,
       selected_date: date,
       events: events_in_month(date)
     )}
  end

  @impl true
  def handle_info({Events, [:registration, _], _}, socket) do
    {:noreply, assign(socket, events: events_in_month(socket.assigns.selected_date))}
  end

  def handle_info({:updated_date, %{date: date}}, socket) do
    url = Routes.event_index_path(socket, :index, %{date: Date.to_iso8601(date)})
    socket = push_patch(socket, to: url)

    {:noreply, socket}
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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="mr-auto flex w-full flex-row items-baseline justify-between sm:flex-col">
        <span class="text-2xl font-bold">Events</span>
        <span class="text-sm text-gray-600">Partaj och annat skoj</span>
      </div>

      <div class="lg:grid lg:grid-cols-12 lg:gap-x-16">
        <.live_component
          module={HajWeb.Components.CalendarComponent}
          id="event-calendar"
          highlighted_dates={@events |> Enum.map(&DateTime.to_date(&1.event_date))}
          on_date_pick={fn date -> send(self(), {:updated_date, date}) end}
        />

        <ol class="mt-4 divide-y divide-gray-100 text-sm leading-6 lg:col-span-7 xl:col-span-8">
          <div class="flex flex-col gap-8 pt-4">
            <.event_card :for={event <- @events} event={event} />
            <div :if={Enum.empty?(@events)} class="text-gray-500">
              Inga planerade events den här månaden!
            </div>
          </div>
        </ol>
      </div>
    </div>
    """
  end

  defp event_card(assigns) do
    ~H"""
    <.link navigate={~p"/events/#{@event}"} class="w-full">
      <div class="group relative mx-0 flex flex-row overflow-hidden rounded-xl border bg-white duration-150 hover:bg-gray-50">
        <div :if={@event.image} class="w-32">
          <div
            alt={"Picture of #{@event.name}"}
            class="tmt relative h-full w-full bg-cover bg-center"
            style={"background-image: url('#{image_url(@event.image, 400, 400)}')"}
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

  defp events_in_month(date) do
    month_start = Date.beginning_of_month(date)
    month_end = Date.end_of_month(date)

    Events.list_events_between(month_start, month_end)
  end
end
