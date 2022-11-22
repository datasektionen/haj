defmodule HajWeb.LiveHelpers do
  use Phoenix.Component

  alias Haj.Accounts
  alias HajWeb.Endpoint
  alias HajWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.JS

  def home_path(), do: Routes.dashboard_path(Endpoint, :index)

  attr :name, :atom, required: true
  attr :outline, :boolean, default: false
  attr :solid, :boolean, default: false
  attr :mini, :boolean, default: false
  attr :rest, :global, default: %{class: "w-4 h-4 inline_block"}

  def icon(assigns) do
    assigns = assign_new(assigns, :"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    ~H"""
    <%= apply(Heroicons, @name, [assigns]) %>
    """
  end

  attr :rows, :list, required: true
  attr :name, :string, default: ""

  slot :col do
    attr :label, :string, required: true
    attr :class, :string
  end

  def live_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="w-full text-sm text-left">
        <thead class="text-xs text-gray-700 uppercase">
          <tr class="border-b-2">
            <%= for col <- @col do %>
              <th scope="col" class={"py-3 pl-2 pr-6 #{col[:class]}"}>
                <%= col.label %>
              </th>
            <% end %>
          </tr>
        </thead>

        <tbody>
          <%= for {row, i} <- Enum.with_index(@rows) do %>
            <tr id={"row_#{i}"} class="hover:bg-gray-50 rounded-full border-b">
              <%= for col <- @col do %>
                <td
                  scope="row"
                  class={"py-4 px-2 font-medium text-gray-900 whitespace-nowrap #{} #{col[:class]}"}
                >
                  <%= render_slot(col, row) %>
                </td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  attr :user, :map

  def user_card(assigns) do
    ~H"""
    <div class="flex flex-row">
      <.link
        navigate={Routes.user_path(Endpoint, :index, @user.username)}
        class="group flex flex-row items-center"
      >
        <img
          src={"https://zfinger.datasektionen.se/user/#{@user.username}/image/100"}
          class="h-8 w-8 rounded-full object-cover object-top inline-block filter group-hover:brightness-90"
        />
        <span class="text-gray-700 text-md px-2 group-hover:text-gray-900">
          <%= full_name(@user) %>
        </span>
      </.link>
    </div>
    """
  end

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-sidebar-container", transition: "fade-in", time: 100)
    |> JS.show(
      to: "#mobile-sidebar",
      display: "flex",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"}
    )
    |> JS.dispatch("js:exec", to: "#hide-mobile-sidebar", detail: %{call: "focus", args: []})
  end

  def hide_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(to: "#mobile-sidebar-container", transition: "fade-out")
    |> JS.hide(
      to: "#mobile-sidebar",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.dispatch("js:exec", to: "#show-mobile-sidebar", detail: %{call: "focus", args: []})
  end

  # @doc """
  # Renders a flash, maybe this looks better on top than bottom?
  # """

  # attr :flash, :map
  # attr :kind, :atom

  # def flash(%{kind: :error} = assigns) do
  #   ~H"""
  #   <%= if live_flash(@flash, @kind) do %>
  #     <div
  #       id="flash"
  #       class="rounded-md bg-red-50 p-4 fixed bottom-4 left-4 right-4 sm:left-auto sm:w-96 fade-in-scale z-50"
  #       phx-click={
  #         JS.push("lv:clear-flash")
  #         |> JS.remove_class("fade-in-scale", to: "#flash")
  #         |> hide("#flash")
  #       }
  #       phx-hook="Flash"
  #     >
  #       <div class="flex justify-between items-center gap-3 text-red-700">
  #         <.icon name={:exclamation_circle} />
  #         <p class="flex-1 text-sm font-medium">
  #           <%= live_flash(@flash, @kind) %>
  #         </p>
  #         <button class="inline-flex bg-red-50 rounded-md text-red-700 focus:outline-none focus:ring-2
  #                        focus:ring-offset-2 focus:ring-offset-red-50 focus:ring-red-700">
  #           <.icon name={:x_mark} class="w-5 h-5" />
  #         </button>
  #       </div>
  #     </div>
  #   <% end %>
  #   """
  # end

  # def flash(%{kind: :info} = assigns) do
  #   ~H"""
  #   <%= if live_flash(@flash, @kind) do %>
  #     <div
  #       id="flash"
  #       class="rounded-md bg-blue-50 p-4 fixed bottom-4 left-4 right-4 sm:left-auto sm:w-96 fade-in-scale z-50"
  #       phx-click={
  #         JS.push("lv:clear-flash")
  #         |> JS.remove_class("fade-in-scale", to: "#flash")
  #         |> hide("#flash")
  #       }
  #       phx-hook="Flash"
  #     >
  #       <div class="flex justify-between items-center gap-3 text-blue-700">
  #         <.icon name={:exclamation_circle} />
  #         <p class="flex-1 text-sm font-medium">
  #           <%= live_flash(@flash, @kind) %>
  #         </p>
  #         <button class="inline-flex bg-blue-50 rounded-md text-blue-700 focus:outline-none focus:ring-2
  #                        focus:ring-offset-2 focus:ring-offset-blue-50 focus:ring-blue-700">
  #           <.icon name={:x_mark} class="w-5 h-5" />
  #         </button>
  #       </div>
  #     </div>
  #   <% end %>
  #   """
  # end

  def full_name(%Accounts.User{} = user), do: "#{user.first_name} #{user.last_name}"

  def format_date(%struct{} = date) when struct in [NaiveDateTime, DateTime] do
    Calendar.strftime(date, "%c")
  end

  def format_date(other), do: other
end
