defmodule HajWeb.SearchComponent do
  use HajWeb, :live_component
  alias Haj.Accounts

  def mount(socket) do
    {:ok, assign(socket, query: "", results: [])}
  end

  def handle_event("search", %{"search_form" => %{"q" => q}}, socket) do
    results = Accounts.search_spex_users(q)

    {:noreply, assign(socket, query: q, results: results)}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, assign(socket, query: "", results: [])}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-grow md:flex-grow-0 md:w-80 lg:w-96 flex-row items-center justify-end gap-4">
      <button phx-click={open_search()} id="search-icon" class="text-gray-700 hover:text-gray-500">
        <.icon name={:magnifying_glass} outline class="h-8 w-8" />
      </button>

      <button
        phx-click={close_search(@myself)}
        id="close-search-icon"
        class="text-gray-700 hover:text-gray-500"
        style="display: none;"
      >
        <.icon name={:x_mark} outline class="h-8 w-8" />
      </button>

      <div id="search-form" class="w-full flex flex-row items-center gap-2" style="display: none;">
        <div class="w-full relative">
          <.form
            :let={f}
            for={:search_form}
            phx-change="search"
            phx-target={@myself}
            class="w-full"
            onkeydown="return event.key != 'Enter';"
            autocomplete={:off}
          >
            <%= text_input(f, :q,
              value: @query,
              phx_debounce: 500,
              placeholder: "Sök",
              class:
                "rounded-lg text-sm h-10 w-full focus:outline-none focus:ring-2 focus:ring-burgandy-700/80 focus:border-none"
            ) %>
          </.form>
          <%= if @results != [] do %>
            <div
              id="search-results"
              class="absolute top-12 left-0 right-0 flex flex-col bg-white rounded-lg border shadow-sm z-10"
            >
              <%= for result <- @results do %>
                <.link
                  navigate={~p"/live/user/#{result.username}"}
                  class="last:border-none border-b py-2 px-3 text-base hover:bg-gray-50"
                >
                  <div><%= full_name(result) %></div>
                  <div class="text-gray-600 text-sm">Person</div>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp open_search() do
    JS.hide(to: "#search-icon")
    |> JS.show(
      to: "#search-form",
      display: "flex"
    )
    |> JS.add_class("hidden md:block", to: "#show-mobile-sidebar")
    |> JS.show(to: "#close-search-icon")
    |> JS.focus(to: "#search-form input")
    |> JS.add_class("hidden xs:flex", to: "#tobar-right")
  end

  defp close_search(target) do
    JS.hide(to: "#search-form")
    |> JS.hide(to: "#close-search-icon")
    |> JS.show(to: "#search-icon")
    |> JS.remove_class("hidden md:block", to: "#show-mobile-sidebar")
    |> JS.remove_class("hidden xs:flex", to: "#tobar-right")
    |> JS.push("clear", target: target)
  end
end
