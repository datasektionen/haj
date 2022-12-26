defmodule HajWeb.EventLive.Index do
  use HajWeb, :live_view

  alias Haj.Events
  alias Haj.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, events: list_events(), counter: 0)}
  end

  def handle_params(_params, _url, socket) do
    IO.inspect(socket.assigns.live_action)
    {:noreply, socket}
  end

  defp list_events do
    Events.list_events()
  end

  defp event_card(assigns) do
    ~H"""
      <section class="flex mt-10 max-w-3xl">
        <div class="relative w-60 h-60">
          <img class="w-full h-full z-0" src="https://scontent.fume1-1.fna.fbcdn.net/v/t1.6435-9/180978949_314228950059549_1005358403722529104_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=OV5A6IRvacEAX-IYTns&_nc_ht=scontent.fume1-1.fna&oh=00_AfCKCCvvZrn9SkGwJMxWgbZ7fs7Z67TTvCQshL7xSgdXpA&oe=63D1628E" />
          <div class="absolute flex flex-col justify-center align-center w-full h-1/3 bottom-0 bg-black opacity-75 z-10 p-5">
            <p class="text-white text-2xl"><%= @event.ticket_limit %></p>
            <p class="text-white">Available tickets</p>
          </div>
        </div>
        <div class="flex-1 ml-5">
          <div>
            <div class="flex place-content-between mb-5">
              <h3 class="text-3xl"><%= @event.name %></h3>
              <div><%= @event.event_date %></div>
            </div>
            <div>Lorem ipsum, dolor sit amet consectetur adipisicing elit. Facere non perferendis libero quia quisquam dolores reiciendis excepturi molestiae odio quos dignissimos iure obcaecati, quaerat nobis! Perspiciatis inventore eveniet commodi et.</div>
          </div>
        </div>
      </section>
      <hr />
    """
  end
end
