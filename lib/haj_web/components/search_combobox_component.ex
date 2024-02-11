defmodule HajWeb.Components.SearchComboboxComponent do
  use HajWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(query: "", results: [], chosen: nil)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    results =
      socket.assigns.search_fn.(query)
      |> Enum.take(5)

    IO.inspect(results)
    {:noreply, assign(socket, results: results, query: query)}
  end

  @impl true
  def handle_event("chosen", %{"chosen" => chosen}, socket) do
    chosen_result =
      Enum.find(socket.assigns.results, fn result ->
        Phoenix.HTML.Safe.to_iodata(result) == chosen
      end)

    {:noreply, assign(socket, chosen: chosen_result.id, query: chosen, results: [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <label for="combobox" class="block text-sm font-medium leading-6 text-gray-900">
          <%= @label %>
        </label>
        <div class="relative mt-2">
          <input
            id="combobox"
            type="text"
            class="py-[7px] px-[11px] mt-2 block w-full rounded-lg border-zinc-300 text-zinc-900 focus:ring-zinc-800/5 focus:border-zinc-400 focus:outline-none focus:ring-4 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:ring-zinc-800/5 phx-no-feedback:focus:border-zinc-400 sm:text-sm sm:leading-6"
            role="combobox"
            aria-controls="options"
            aria-expanded="false"
            placeholder="Sök..."
            phx-target={@myself}
            phx-change="search"
            name="q"
            value={@query}
            autocomplete={:off}
          />
          <button
            type="button"
            class="absolute inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:outline-none"
          >
            <svg
              class="h-5 w-5 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M10 3a.75.75 0 01.55.24l3.25 3.5a.75.75 0 11-1.1 1.02L10 4.852 7.3 7.76a.75.75 0 01-1.1-1.02l3.25-3.5A.75.75 0 0110 3zm-3.76 9.2a.75.75 0 011.06.04l2.7 2.908 2.7-2.908a.75.75 0 111.1 1.02l-3.25 3.5a.75.75 0 01-1.1 0l-3.25-3.5a.75.75 0 01.04-1.06z"
                clip-rule="evenodd"
              />
            </svg>
          </button>

          <div
            :if={@results != []}
            class="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
            id="options"
            role="listbox"
          >
            <li
              :for={result <- @results}
              class="relative cursor-default select-none py-2 pr-9 pl-3 text-gray-900 hover:bg-gray-50"
              role="option"
              tabindex="-1"
              phx-click={JS.push("chosen", value: %{chosen: Phoenix.HTML.Safe.to_iodata(result)})}
              phx-target={@myself}
            >
              <span class={[
                "block truncate",
                @chosen == Phoenix.HTML.Safe.to_iodata(result) && "font-semibold"
              ]}>
                <%= result %>
              </span>

              <span
                :if={@chosen == result}
                class="absolute inset-y-0 right-0 flex items-center pr-4 text-indigo-600"
              >
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path
                    fill-rule="evenodd"
                    d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                    clip-rule="evenodd"
                  />
                </svg>
              </span>
            </li>
          </div>
        </div>
      </div>

      <.input field={@field} type="hidden" value={@chosen} />
    </div>
    """
  end
end
