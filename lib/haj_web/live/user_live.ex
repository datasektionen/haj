defmodule HajWeb.UserLive do
  use HajWeb, :live_view
  alias Haj.Accounts
  alias HajWeb.Endpoint

  def mount(%{"username" => username}, _session, socket) do
    user = Accounts.get_user_by_username!(username) |> Accounts.preload(:foods)

    groups = Haj.Spex.get_show_groups_for_user(user.id)
    groups_by_year = Enum.group_by(groups, fn %{show: show} -> show.year end)

    {:ok, assign(socket, user: user, groups: groups_by_year)}
  end

  def render(assigns) do
    ~H"""
    <div class="pt-4">
      <div class="flex flex-row items-center gap-4 pb-4">
        <img
          src={"https://zfinger.datasektionen.se/user/#{@user.username}/image/200"}
          class="h-20 w-20 rounded-full object-cover object-top inline-block filter group-hover:brightness-90"
        />
        <div class="flex flex-col">
          <span class="text-2xl font-bold"><%= "#{@user.first_name} #{@user.last_name}" %></span>
          <span class="text-sm text-gray-600"><%= "#{@user.username}@kth.se" %></span>
        </div>
      </div>
      <div class="flex flex-col sm:flex-row sm:gap-8 justify-start w-full">
        <div class="sm:flex-grow">
          <h3 class="text-lg py-3 font-bold px-2 border-b border-burgandy-500">Uppgifter</h3>
          <dl>
            <.datalist_item description="KTH-id" data={@user.username} />
            <.datalist_item description="Klass" data={@user.class} />
            <.datalist_item description="Email" data={@user.email} />
            <.datalist_item description="Google-konto" data={@user.google_account} />
            <.datalist_item description="Telefonnummer" data={@user.phone} />
            <.datalist_item description="Matpreferenser" data={display_foods(@user)} />
          </dl>
        </div>
        <div class="sm:w-64">
          <h3 class="text-lg py-3 font-bold px-2 border-b border-burgandy-500">Grupper</h3>

          <%= for {year, show_groups} <- @groups do %>
            <div>
              <div class="py-2 px-2 font-bold text-sm border-b border-burgandy-500">
                <%= year.year %>
              </div>

              <%= for show_group <- show_groups do %>
                <.link
                  navigate={Routes.group_path(Endpoint, :index, show_group.id)}
                  class="block px-2 py-3 border-b hover:bg-gray-50 text-sm"
                >
                  <%= show_group.group.name %>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp display_foods(user) do
    prefs = Enum.map(user.foods, fn %{name: name} -> name end) |> Enum.join(", ")

    case user.food_preference_other do
      nil -> prefs
      other -> prefs <> ". " <> other
    end
  end

  defp datalist_item(%{class: _class} = assigns) do
    ~H"""
    <div class={"bg-white py-3 px-2 border-b sm:grid sm:grid-cols-3 sm:gap-2 #{@class}"}>
      <dt class="text-sm text-gray-400"><%= @description %></dt>
      <dd class="mt-1 text-sm text-gray-900 sm:col-span-2 sm:mt-0"><%= @data %></dd>
    </div>
    """
  end

  defp datalist_item(assigns), do: datalist_item(Map.put(assigns, :class, ""))
end
