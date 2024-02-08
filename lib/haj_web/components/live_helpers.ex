defmodule HajWeb.LiveHelpers do
  use Phoenix.Component

  alias Haj.Accounts
  alias HajWeb.Endpoint
  alias HajWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.JS

  use Phoenix.VerifiedRoutes,
    endpoint: HajWeb.Endpoint,
    router: HajWeb.Router,
    statics: HajWeb.static_paths()

  def home_path(), do: ~p"/dashboard"

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
      <table class="w-full text-left text-sm">
        <thead class="text-xs uppercase text-gray-700">
          <tr class="border-b-2">
            <%= for col <- @col do %>
              <th scope="col" class={"#{col[:class]} py-3 pr-6 pl-2"}>
                <%= col.label %>
              </th>
            <% end %>
          </tr>
        </thead>

        <tbody>
          <%= for {row, i} <- Enum.with_index(@rows) do %>
            <tr id={"row_#{i}"} class="rounded-full border-b hover:bg-gray-50">
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
          src={"https://#{Application.get_env(:haj, :zfinger_url)}/user/#{@user.username}/image/100"}
          class="inline-block h-8 w-8 rounded-full object-cover object-top filter group-hover:brightness-90"
        />
        <span class="text-md px-2 text-gray-700 group-hover:text-gray-900">
          <%= full_name(@user) %>
        </span>
      </.link>
    </div>
    """
  end

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#mobile-sidebar-container",
      transition: {"transition fade-in duration-300", "opacity-0", "opacity-100"},
      time: 300
    )
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

  def full_name(%Accounts.User{} = user), do: "#{user.first_name} #{user.last_name}"

  def format_date(%struct{} = date) when struct in [NaiveDateTime, DateTime] do
    Calendar.strftime(date, "%c")
  end

  def format_date(other), do: other

  @colors ~w"#8dd3c7 #ffffb3 #bebada #fb8072 #80b1d3 #fdb462 #b3de69 #fccde5 #d9d9d9 #bc80bd #ccebc5 #ffed6f"

  def get_color(:bg, index), do: Enum.at(@colors, rem(index - 1, 12), "#4e79a7")

  def pick_text_color(hex_color) do
    colors = hex_to_rgb(hex_color)

    colors = for {k, v} <- colors, into: %{}, do: {k, get_modified_rgb(v)}

    # Calculate luminance
    luminance = 0.2126 * colors.red + 0.7152 * colors.green + 0.0722 * colors.blue

    if luminance > 0.179 do
      "#000000"
    else
      "#ffffff"
    end
  end

  defp hex_to_rgb(<<"#", hex::binary>>) do
    hex_to_rgb(hex)
  end

  defp hex_to_rgb(
         <<hex_red::binary-size(2), hex_green::binary-size(2), hex_blue::binary-size(2)>>
       ) do
    %{
      red: Integer.parse(hex_red, 16) |> elem(0),
      blue: Integer.parse(hex_blue, 16) |> elem(0),
      green: Integer.parse(hex_green, 16) |> elem(0)
    }
  end

  defp get_modified_rgb(c) do
    c = c / 255.0

    if c <= 0.04045 do
      c / 12.92
    else
      :math.pow((c + 0.055) / 1.055, 2.4)
    end
  end

  def swe_month_name(month) do
    {"januari", "februari", "mars", "april", "maj", "juni", "juli", "augusti", "september",
     "oktober", "november", "december"}
    |> elem(month - 1)
  end

  def swe_day_name(day) do
    {"Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"}
    |> elem(day - 1)
  end
end
