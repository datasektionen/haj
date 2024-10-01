defmodule HajWeb.UserLive do
  use HajWeb, :live_view
  alias Haj.Accounts

  def mount(%{"username" => username}, _session, socket) do
    user = Accounts.get_user_by_username!(username) |> Accounts.preload(:foods)

    groups = Haj.Spex.get_show_groups_for_user(user.id)

    groups_by_year =
      Enum.sort_by(groups, &{&1.show.year, &1.group.name})
      |> Enum.group_by(fn %{show: show} -> show.year end)

    {:ok, assign(socket, page_title: full_name(user), user: user, groups: groups_by_year)}
  end

  def render(assigns) do
    ~H"""
    <div class="">
      <div class="flex flex-row items-center gap-4 pb-4">
        <img
          src={"https://#{Application.get_env(:haj, :zfinger_url)}/user/#{@user.username}/image/200"}
          class="inline-block h-20 w-20 rounded-full object-cover object-top filter group-hover:brightness-90"
        />
        <div class="flex flex-col">
          <span class="text-2xl font-bold"><%= full_name(@user) %></span>
          <span class="text-sm text-gray-600"><%= "#{@user.username}@kth.se" %></span>
        </div>
      </div>
      <div class="flex w-full flex-col justify-start sm:flex-row sm:gap-8">
        <div class="rounded-xl border border-slate-200 p-8">
          <h3 class="border-burgandy-500 border-b px-2 py-3 text-lg font-bold">Uppgifter</h3>
          <dl>
            <.datalist_item description="KTH-id" data={@user.username} />
            <.datalist_item description="Klass" data={@user.class} />
            <.datalist_item description="Email" data={@user.email} />
            <.datalist_item description="Google-konto" data={@user.google_account} />
            <.datalist_item description="Telefonnummer" data={@user.phone} />
            <.datalist_item description="Matpreferenser" data={display_foods(@user)} />
          </dl>
        </div>
        <div class="rounded-xl border border-slate-200 p-8 sm:w-64">
          <h3 class="border-burgandy-500 border-b px-2 py-3 text-lg font-bold">Grupper</h3>

          <%= for {year, show_groups} <- @groups do %>
            <div>
              <div class="border-burgandy-500 border-b px-2 py-2 text-sm font-bold">
                <%= year.year %>
              </div>

              <%= for show_group <- show_groups do %>
                <.link
                  navigate={~p"/group/#{show_group.id}"}
                  class="block border-b px-2 py-3 text-sm hover:bg-gray-50"
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
    <div class={"#{@class} border-b bg-white px-2 py-3 sm:grid sm:grid-cols-3 sm:gap-2"}>
      <dt class="text-sm text-gray-400"><%= @description %></dt>
      <dd class="mt-1 text-sm text-gray-900 sm:col-span-2 sm:mt-0"><%= @data %></dd>
    </div>
    """
  end

  defp datalist_item(assigns), do: datalist_item(Map.put(assigns, :class, ""))
end
