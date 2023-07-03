defmodule HajWeb.SearchComponent do
  use HajWeb, :live_component
  alias Haj.Archive
  alias Haj.Accounts
  alias Haj.Spex
  alias Haj.Responsibilities
  alias Haj.Policy

  def update(assigns, socket) do
    {:ok, assign(socket, assigns) |> assign(q: "", results: [])}
  end

  def handle_event("search", %{"search_form" => %{"q" => q}}, socket) do
    current_spex = Spex.current_spex()

    responsibilities =
      if Policy.authorize?(:responsibility_read, socket.assigns.user) do
        Responsibilities.search_responsibilities(q, rank: true)
      else
        []
      end

    # Sort results based on similarity
    results =
      Accounts.search_spex_users(q, rank: true)
      |> Enum.concat(Spex.search_show_groups(current_spex.id, q, rank: true))
      |> Enum.concat(Archive.search_songs(q, rank: true))
      |> Enum.concat(responsibilities)
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> Enum.map(&elem(&1, 0))

    {:noreply, assign(socket, q: q, results: results)}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, assign(socket, q: "", results: [])}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-grow flex-row items-center justify-end gap-4 md:w-80 md:flex-grow-0 lg:w-96">
        <button phx-click={open_search()} id="search-icon" class="text-gray-700 hover:text-gray-500">
          <.icon name={:magnifying_glass} solid class="h-8 w-8" />
        </button>
      </div>

      <.focus_wrap id="search-modal">
        <div
          id="searchbar-dialog"
          class="fixed inset-0 z-50 hidden"
          role="dialog"
          aria-modal="true"
          phx-window-keydown={close_search()}
          phx-key="escape"
        >
          <div class="bg-gray-400/10 fixed inset-0 opacity-100 backdrop-blur-sm"></div>

          <div class="fixed inset-0 overflow-y-auto px-4 py-4 sm:px-6 sm:py-20 md:py-32 lg:py-[15vh] lg:px-8">
            <button
              phx-click={close_search(@myself)}
              id="close-search-icon"
              class="text-gray-700 hover:text-gray-500"
              style="display: none;"
            >
              <.icon name={:x_mark} outline class="h-8 w-8" />
            </button>

            <div
              id="search-form"
              class="ring-gray-900/7.5 mx-auto scale-100 overflow-hidden rounded-lg bg-gray-50 opacity-100 shadow-xl sm:max-w-xl"
              style="display: none;"
              phx-hook="SearchElement"
            >
              <div
                class="relative w-full"
                role="combobox"
                aria-haspopup="listbox"
                phx-click-away={close_search()}
                aria-expanded={@results != []}
              >
                <.form
                  :let={f}
                  as={:search_form}
                  phx-change="search"
                  phx-target={@myself}
                  class="relative h-14 w-full bg-white"
                  onkeydown="return event.key != 'Enter';"
                  autocomplete={:off}
                >
                  <.icon
                    name={:magnifying_glass}
                    mini
                    class="pointer-events-none absolute top-0 left-3 h-full w-4 text-gray-600"
                  />
                  <%= text_input(f, :q,
                    value: @q,
                    phx_debounce: 500,
                    placeholder: "Sök i Haj",
                    id: "search-input",
                    class: [
                      "w-full h-full pl-10 flex-auto rounded-lg bg-transparent text-sm outline-none appearance-none border-gray-200",
                      "focus:ring-burgandy-700/80 focus:border-gray-200 focus:outline-none focus:ring-0 placeholder:text-gray-600"
                    ],
                    style:
                      @results != [] &&
                        "border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: none",
                    autocomplete: "off",
                    autocorrect: "off",
                    type: "search"
                  ) %>
                </.form>
                <div
                  :if={@results != []}
                  id="search-results"
                  class="flex flex-col overflow-y-auto rounded-b-lg border bg-white leading-6"
                  role="listbox"
                >
                  <.link
                    :for={result <- @results}
                    navigate={navigate(result)}
                    class="border-b px-3 py-2 text-base last:border-none hover:bg-gray-50 focus:text-burgandy-800 focus:bg-gray-50 focus:outline-none"
                  >
                    <div><%= title(result) %></div>
                    <div class="text-sm text-gray-600"><%= type(result) %></div>
                  </.link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </.focus_wrap>
    </div>
    """
  end

  defp navigate(%Accounts.User{} = user), do: ~p"/user/#{user.username}"
  defp navigate(%Spex.ShowGroup{} = sg), do: ~p"/group/#{sg.id}"
  defp navigate(%Archive.Song{} = song), do: ~p"/songs/#{song.id}"

  defp navigate(%Responsibilities.Responsibility{} = responsibility),
    do: ~p"/responsibilities/#{responsibility.id}"

  defp title(%Accounts.User{} = user), do: full_name(user)
  defp title(%Spex.ShowGroup{} = sg), do: sg.group.name
  defp title(%Archive.Song{name: name}), do: name
  defp title(%Responsibilities.Responsibility{name: name}), do: name

  defp type(%Accounts.User{}), do: "Person"
  defp type(%Spex.ShowGroup{}), do: "Grupp"
  defp type(%Archive.Song{}), do: "Låt"
  defp type(%Responsibilities.Responsibility{}), do: "Ansvar"

  defp open_search(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#search-form",
      display: "flex"
    )
    |> JS.show(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-0", "opacity-100"}
    )
    |> JS.focus(to: "#search-form input")

    #
    # |>
    # |> JS.add_class("hidden md:block", to: "#show-mobile-sidebar")
    # |> JS.show(to: "#close-search-icon")
    # |> JS.focus(to: "#search-form input")
    # |> JS.add_class("hidden xs:flex", to: "#tobar-right")
  end

  defp close_search(js \\ %JS{}) do
    JS.hide(to: "#search-form")
    |> JS.hide(to: "#close-search-icon")
    |> JS.hide(to: "#searchbar-dialog")
    |> JS.show(to: "#search-icon")
    |> JS.remove_class("hidden md:block", to: "#show-mobile-sidebar")
    |> JS.remove_class("hidden xs:flex", to: "#tobar-right")
  end
end
