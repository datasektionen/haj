defmodule HajWeb.Components.CalendarComponent do
  @moduledoc false
  use Phoenix.LiveComponent

  @week_start :monday

  def mount(socket) do
    current_date = Date.utc_today()

    assigns = [
      current_date: current_date,
      selected_date: current_date,
      highlighted_dates: [],
      dates: dates(current_date),
      on_date_pick: fn _ -> nil end
    ]

    {:ok, assign(socket, assigns)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("prev-month", _params, socket) do
    new_date = socket.assigns.selected_date |> Date.beginning_of_month() |> Date.add(-1)

    assign_new_date(socket, new_date)
  end

  def handle_event("next-month", _params, socket) do
    new_date = socket.assigns.selected_date |> Date.end_of_month() |> Date.add(1)

    assign_new_date(socket, new_date)
  end

  def handle_event("pick-date", %{"date" => date}, socket) do
    date = Date.from_iso8601!(date)

    if date != socket.assigns.selected_date do
      assign_new_date(socket, date)
    else
      {:noreply, socket}
    end
  end

  defp assign_new_date(socket, date) do
    # Notify parent callback
    socket.assigns.on_date_pick.(%{date: date})

    {:noreply, assign(socket, selected_date: date, dates: dates(date))}
  end

  def render(assigns) do
    ~H"""
    <div class="mt-10 text-center lg:col-start-8 lg:col-end-13 lg:row-start-1 lg:mt-9 xl:col-start-9">
      <div class="flex items-center text-gray-900">
        <button
          type="button"
          class="-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500"
          phx-target={@myself}
          phx-click="prev-month"
        >
          <span class="sr-only">Previous month</span>
          <svg
            class="h-5 w-5"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
            data-slot="icon"
          >
            <path
              fill-rule="evenodd"
              d="M11.78 5.22a.75.75 0 0 1 0 1.06L8.06 10l3.72 3.72a.75.75 0 1 1-1.06 1.06l-4.25-4.25a.75.75 0 0 1 0-1.06l4.25-4.25a.75.75 0 0 1 1.06 0Z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
        <div class="flex-auto text-sm font-semibold">
          <%= Calendar.strftime(@selected_date, "%B %Y") %>
        </div>
        <button
          type="button"
          class="-m-1.5 flex flex-none items-center justify-center p-1.5 text-gray-400 hover:text-gray-500"
          phx-target={@myself}
          phx-click="next-month"
        >
          <span class="sr-only">Next month</span>
          <svg
            class="h-5 w-5"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
            data-slot="icon"
          >
            <path
              fill-rule="evenodd"
              d="M8.22 5.22a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06-1.06L11.94 10 8.22 6.28a.75.75 0 0 1 0-1.06Z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      </div>
      <div class="mt-6 grid grid-cols-7 text-xs leading-6 text-gray-500">
        <div :for={day <- ~w"M T W T F S S"}><%= day %></div>
      </div>

      <div class="isolate mt-2 grid grid-cols-7 gap-px rounded-lg bg-gray-200 text-sm shadow ring-1 ring-gray-200">
        <button
          :for={{date, index} <- Enum.with_index(@dates)}
          type="button"
          phx-target={@myself}
          phx-click="pick-date"
          phx-value-date={Calendar.strftime(date, "%Y-%m-%d")}
          class={[
            button_class_styling(date, @current_date, @selected_date),
            button_corner_styling(index, length(@dates))
          ]}
        >
          <time
            datetime={Calendar.strftime(date, "%Y-%m-%d")}
            class={time_styling(date, @current_date, @selected_date, @highlighted_dates)}
          >
            <%= Calendar.strftime(date, "%d") %>
          </time>
        </button>
      </div>
    </div>
    """
  end

  defp dates(date) do
    first =
      Date.beginning_of_month(date)
      |> Date.beginning_of_week(@week_start)

    last = Date.end_of_month(date) |> Date.end_of_week(@week_start)

    Date.range(first, last)
    |> Enum.to_list()
  end

  # Always include: "py-1.5 hover:bg-gray-100 focus:z-10"
  # Is current month, include: "bg-white"
  # Is not current month, include: "bg-gray-50"
  # Is selected or is today, include: "font-semibold"
  # Is selected, include: "text-white"
  # Is not selected, is not today, and is current month, include: "text-gray-900"
  # Is not selected, is not today, and is not current month, include: "text-gray-400"
  # Is today and is not selected, include: "text-burgandy-600"

  defp button_class_styling(date, current_date, selected_date) do
    current_month = Date.beginning_of_month(date) == Date.beginning_of_month(selected_date)
    today = Date.to_string(date) == Date.to_string(current_date)
    selected = selected_date == date

    ["py-1.5", "hover:bg-gray-100", "focus:z-10"]
    |> add_class_if(current_month, "bg-white", "bg-gray-50")
    |> add_class_if(selected || today, "font-semibold")
    |> add_class_if(selected, "text-white")
    |> add_class_if(!selected && !today && current_month, "text-gray-900")
    |> add_class_if(!selected && !today && !current_month, "text-gray-400")
    |> add_class_if(today && !selected, "text-burgandy-600")
    |> Enum.join(" ")
  end

  # Always include: "mx-auto flex h-7 w-7 items-center justify-center rounded-full"
  # Is selected and is today, include: "bg-burgandy-600"
  # Is selected and is not today, include: "bg-gray-900"
  defp time_styling(date, current_date, selected_date, highlighted_dates \\ []) do
    today = Date.to_string(date) == Date.to_string(current_date)
    selected = selected_date == date

    ["mx-auto", "flex", "h-7", "w-7", "items-center", "justify-center", "rounded-full"]
    |> add_class_if(date in highlighted_dates && !selected, "bg-burgandy-100")
    |> add_class_if(selected && today, "bg-burgandy-600")
    |> add_class_if(selected && !today, "bg-gray-900")
    |> Enum.join(" ")
  end

  # Top left day, include: "rounded-tl-lg"
  # Top right day, include: "rounded-tr-lg"
  # Bottom left day, include: "rounded-bl-lg"
  # Bottom right day, include: "rounded-br-lg"

  defp button_corner_styling(index, total_dates) do
    last_row = div(total_dates, 7) - 1

    cond do
      index == 0 -> "rounded-tl-lg"
      index == 6 -> "rounded-tr-lg"
      index == last_row * 7 -> "rounded-bl-lg"
      index == last_row * 7 + 6 -> "rounded-br-lg"
      true -> ""
    end
  end

  defp add_class_if(classes, condition, class, else_class \\ nil) do
    cond do
      condition -> [class | classes]
      else_class != nil -> [else_class | classes]
      true -> classes
    end
  end
end
