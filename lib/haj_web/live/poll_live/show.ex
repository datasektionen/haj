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
    |> assign(:page_title, "Nytt alternativ")
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
      <div class="flex flex-col items-center justify-between xs:flex-row">
        <div class="mr-auto flex w-full flex-col items-baseline justify-between pt-4">
          <span class="text-2xl font-bold"><%= @poll.title %></span>
          <span class="text-sm text-gray-600"><%= @poll.description %></span>
        </div>

        <div class="mt-4 w-full flex-none xs:w-fit">
          <.link patch={~p"/polls/#{@poll}/add-option"}>
            <.button class="w-full">Nytt alternativ</.button>
          </.link>
        </div>
      </div>

      <ul role="list" phx-update="stream" id="options" class="divide-y divide-gray-100">
        <div
          :for={{id, option} <- @streams.options}
          id={id}
          class="flex flex-col rounded-md px-2 py-5 hover:bg-gray-50 sm:flex-nowrap"
        >
          <div class="flex flex-wrap items-center justify-between gap-x-2">
            <label
              phx-click="vote"
              phx-value-id={option.id}
              class="px-2 py-2 hover:cursor-pointer md:px-4"
            >
              <input
                type="checkbox"
                class="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900"
                checked={option.voted}
              />
            </label>

            <div class="mr-auto">
              <p class="text-sm/6 font-semibold">
                <.link
                  :if={option.url}
                  href={option.url}
                  target="_blank"
                  class="text-burgandy-600 hover:underline"
                >
                  <%= option.name %>
                </.link>
                <span :if={!option.url}><%= option.name %></span>
              </p>
            </div>
            <div class="flex w-16 gap-x-2.5 pl-4">
              <dt class="flex items-center">
                <span class="sr-only">Total votes</span>
                <.icon name={:user} class="h-4 w-4 text-gray-400" />
              </dt>
              <dd class="text-sm/6 text-gray-900">
                <%= option.votes %>
              </dd>
            </div>
          </div>

          <p
            :if={option.description}
            class="text-xs/5 mt-1 ml-2 flex items-center gap-x-2 text-gray-500 md:ml-4"
          >
            <%= option.description %>
          </p>
        </div>
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
