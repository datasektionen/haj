defmodule HajWeb.EventLive.Registrations.Index do
  use HajWeb, :live_view

  on_mount {HajWeb.UserAuth, {:authorize, :event_registrations_read}}

  alias Haj.Events

  @impl true
  def mount(%{"id" => _}, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    event = Events.get_event!(id, form: [:questions])
    registrations = Events.list_event_registrations(id)

    most_popular =
      Enum.filter(registrations, & &1.attending)
      |> Enum.flat_map(& &1.user.group_memberships)
      |> Enum.map(& &1.show_group.group)
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_, c} -> c end, &>=/2)
      |> Enum.take(1)
      |> Enum.map(fn {group, _} -> group.name end)

    {:noreply,
     assign(socket, event: event, registrations: registrations, most_popular: most_popular)
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("select_tab", %{"tab" => tab}, socket) do
    event = socket.assigns.event

    path =
      case tab do
        "users" -> ~p"/events/#{event}/registrations/users"
        "food" -> ~p"/events/#{event}/registrations/food"
        "questions" -> ~p"/events/#{event}/registrations/questions"
      end

    {:noreply, push_patch(socket, to: path)}
  end

  defp apply_action(socket, :users, _params), do: assign(socket, page_title: "Anmälda")

  defp apply_action(socket, :food, _params) do
    food_counts =
      Enum.filter(socket.assigns.registrations, & &1.attending)
      |> Enum.flat_map(& &1.user.foods)
      |> Enum.group_by(& &1.id, & &1.name)
      |> Enum.flat_map(fn {_key, values} -> Enum.frequencies(values) end)
      |> Enum.sort_by(fn c -> c end, &>=/2)

    special_users =
      Enum.map(socket.assigns.registrations, & &1.user)
      |> Enum.reject(&(&1.food_preference_other == nil))

    assign(socket, food_counts: food_counts, special_food_users: special_users)
  end

  defp apply_action(socket, :questions, _params) do
    response_counts =
      Enum.map(socket.assigns.registrations, & &1.response)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(& &1.question_responses)
      |> Enum.group_by(& &1.question_id, &(&1.answer || &1.multi_answer))
      |> Enum.map(fn {key, values} ->
        {key, Enum.frequencies(List.flatten(values)) |> Enum.sort_by(fn {_, c} -> c end, &>=/2)}
      end)
      |> Enum.into(%{})

    group_counts =
      Enum.flat_map(socket.assigns.registrations, & &1.user.group_memberships)
      |> Enum.map(& &1.show_group.group)
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_, c} -> c end, &>=/2)

    class_counts =
      Enum.map(socket.assigns.registrations, & &1.user.class)
      |> Enum.frequencies()
      |> Map.drop([nil])
      |> Enum.sort_by(fn {_, c} -> c end, &>=/2)

    assign(socket,
      response_counts: response_counts,
      group_counts: group_counts,
      class_counts: class_counts
    )
  end

  defp tab(assigns) do
    ~H"""
    <.link
      patch={@navigate}
      class={
        if @active,
          do:
            "whitespace-nowrap border-b-2 border-gray-500 px-1 py-4 text-sm font-medium text-gray-600",
          else:
            "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
      }
    >
      <%= @name %>
    </.link>
    """
  end
end
