defmodule HajWeb.PollLive.Show do
  use HajWeb, :live_view

  alias Haj.Polls
  alias Haj.Polls.Option

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    poll = Polls.get_poll!(id)
    options = Polls.list_options_for_poll(id)
    user_votes = Polls.list_user_votes_for_poll(id, socket.assigns.current_user.id)

    if connected?(socket) do
      Polls.subscribe(id)
    end

    options =
      Enum.map(options, fn option ->
        Map.put(option, :voted, Enum.any?(user_votes, fn vote -> vote.option_id == option.id end))
      end)

    {:ok,
     assign(socket, poll: poll, user_votes: user_votes)
     |> stream(:options, options)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, socket.assigns.poll.title)
    |> assign(:option, nil)
  end

  defp apply_action(socket, :new_option, _params) do
    socket
    |> assign(:page_title, "New Option")
    |> assign(:option, %Option{
      poll_id: socket.assigns.poll.id,
      creator_id: socket.assigns.current_user.id
    })
  end

  @impl true
  def handle_info({HajWeb.OptionLive.FormComponent, {:saved, _option}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_option, %{option: option}}, socket) do
    option =
      Map.put(option, :voted, false)
      |> Map.put(:votes, 0)

    {:noreply, stream_insert(socket, :options, option)}
  end

  @impl true
  def handle_info({:new_vote, %{vote: vote, option: option, position: pos}}, socket) do
    user_votes =
      if vote.user_id == socket.assigns.current_user.id do
        [vote | socket.assigns.user_votes]
      else
        socket.assigns.user_votes
      end

    option = Map.put(option, :voted, Enum.any?(user_votes, fn v -> v.option_id == option.id end))

    {:noreply,
     assign(socket, :user_votes, user_votes)
     |> stream_delete(:options, option)
     |> stream_insert(:options, option, at: pos - 1)}
  end

  @impl true
  def handle_info({:deleted_vote, %{vote: vote, option: option, position: pos}}, socket) do
    user_votes = Enum.reject(socket.assigns.user_votes, fn v -> v.id == vote.id end)
    option = Map.put(option, :voted, Enum.any?(user_votes, fn v -> v.option_id == option.id end))

    {:noreply,
     assign(socket, :user_votes, user_votes)
     |> stream_delete(:options, option)
     |> stream_insert(:options, option, at: pos - 1)}
  end

  @impl true
  def handle_event("vote", %{"id" => id}, socket) do
    {:ok, _} = Polls.toggle_user_vote_for_option(id, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row items-center justify-between">
        <div class="mr-auto flex w-full flex-row items-baseline justify-between pt-4 sm:flex-col">
          <span class="text-2xl font-bold"><%= @poll.title %></span>
          <span class="hidden text-sm text-gray-600 sm:block"><%= @poll.description %></span>
        </div>

        <div class="flex-none">
          <.link patch={~p"/polls/#{@poll}/add-option"}>
            <.button>Nytt alternativ</.button>
          </.link>
        </div>
      </div>

      <ul role="list" phx-update="stream" id="options" class="divide-y divide-gray-100">
        <label
          :for={{id, option} <- @streams.options}
          id={id}
          class="flex flex-wrap items-center justify-between gap-x-6 gap-y-4 rounded-md px-2 py-5 hover:bg-gray-50 sm:flex-nowrap"
          phx-click="vote"
          phx-value-id={option.id}
        >
          <input type="checkbox" checked={option.voted} />

          <div class="mr-auto">
            <p class="text-sm/6 font-semibold text-gray-900">
              <.link href={option.url} class="hover:underline"><%= option.name %></.link>
            </p>
            <div class="text-xs/5 mt-1 flex items-center gap-x-2 text-gray-500">
              <p>
                <%= option.description %>
              </p>
              <svg viewBox="0 0 2 2" class="h-0.5 w-0.5 fill-current">
                <circle cx="1" cy="1" r="1"></circle>
              </svg>
              <p>
                <%= option.creator.full_name %>
              </p>
            </div>
          </div>
          <div class="flex w-16 gap-x-2.5">
            <dt class="flex items-center">
              <span class="sr-only">Total votes</span>
              <.icon name={:user} class="h-5 w-5 text-gray-400" />
            </dt>
            <dd class="text-sm/6 text-gray-900">
              <%= option.votes %>
            </dd>
          </div>
        </label>
      </ul>
    </div>

    <.modal
      :if={@live_action in [:new_option]}
      id="option-modal"
      show
      on_cancel={JS.patch(~p"/polls/#{@poll}")}
    >
      <.live_component
        module={HajWeb.OptionLive.FormComponent}
        id={:new}
        title={@page_title}
        action={:new}
        option={@option}
        patch={~p"/polls/#{@poll}"}
      />
    </.modal>
    """
  end
end
