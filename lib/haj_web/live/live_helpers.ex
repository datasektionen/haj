defmodule HajWeb.LiveHelpers do
  use Phoenix.Component

  alias Haj.Accounts
  alias LiveBeatsWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.JS

  def home_path(), do: "/"

  attr :name, :atom, required: true
  attr :outlined, :boolean, default: false
  attr :mini, :boolean, default: false
  attr :rest, :global, default: %{class: "w-4 h-4 inline_block"}

  def icon(assigns) do
    assigns = assign_new(assigns, :"aria-hidden", fn -> !Map.has_key?(assigns, :"aria-label") end)

    ~H"""
    <%= if @outlined do %>
      <%= apply(Heroicons.Outline, @name, [Map.to_list(@rest)]) %>
    <% else %>
      <%= if @mini do %>
        <%= apply(Heroicons.Mini, @name, [Map.to_list(@rest)]) %>
      <% else %>
        <%= apply(Heroicons.Solid, @name, [Map.to_list(@rest)]) %>
      <% end %>
    <% end %>
    """
  end

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-sidebar-container", transition: "fade-in")
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

  @doc """
  Renders a flash, maybe this looks better on top than bottom?
  """

  attr :flash, :map
  attr :kind, :atom

  def flash(%{kind: :error} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-red-50 p-4 fixed bottom-4 left-4 right-4 sm:left-auto sm:w-96 fade-in-scale z-50"
        phx-click={
          JS.push("lv:clear-flash")
          |> JS.remove_class("fade-in-scale", to: "#flash")
          |> hide("#flash")
        }
      >
        <div class="flex justify-between items-center gap-3 text-red-700">
          <.icon name={:exclamation_circle} />
          <p class="flex-1 text-sm font-medium">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button class="inline-flex bg-red-50 rounded-md text-red-700 focus:outline-none focus:ring-2
                         focus:ring-offset-2 focus:ring-offset-red-50 focus:ring-red-700">
            <.icon name={:x_mark} class="w-5 h-5" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def flash(%{kind: :info} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-blue-50 p-4 fixed bottom-4 left-4 right-4 sm:left-auto sm:w-96 fade-in-scale z-50"
        phx-click={
          JS.push("lv:clear-flash")
          |> JS.remove_class("fade-in-scale", to: "#flash")
          |> hide("#flash")
        }
      >
        <div class="flex justify-between items-center gap-3 text-blue-700">
          <.icon name={:exclamation_circle} />
          <p class="flex-1 text-sm font-medium">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button class="inline-flex bg-blue-50 rounded-md text-blue-700 focus:outline-none focus:ring-2
                         focus:ring-offset-2 focus:ring-offset-blue-50 focus:ring-blue-700">
            <.icon name={:x_mark} class="w-5 h-5" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 300,
      transition:
        {"transition ease-in duration-300", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end
end
