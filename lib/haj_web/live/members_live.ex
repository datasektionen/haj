defmodule HajWeb.MembersLive do
  use HajWeb, :live_view

  alias Haj.Spex
  alias HajWeb.Endpoint

  def mount(_params, _session, socket) do
    %{id: show_id} = Spex.current_spex()

    members = Spex.list_members_for_show(show_id) |> Spex.preload_user_groups()

    groups =
      Spex.get_show_groups_for_show(show_id)
      |> Enum.map(fn %{id: id, group: g} -> [key: g.name, value: id] end)

    socket =
      socket
      |> assign(show_id: show_id, members: members, query: nil, groups: groups, group: nil)

    {:ok, socket}
  end

  def handle_event("filter", %{"search_form" => %{"q" => query, "group" => group}}, socket) do
    members =
      case {group, query} do
        {"", ""} ->
          Spex.list_members_for_show(socket.assigns.show_id) |> Spex.preload_user_groups()

        {group, ""} ->
          Spex.get_group_members(group) |> Spex.preload_user_groups()

        {"", query} ->
          Spex.search_show_members(socket.assigns.show_id, query) |> Spex.preload_user_groups()

        {group, query} ->
          Spex.search_group_members(group, query) |> Spex.preload_user_groups()
      end

    {:noreply, assign(socket, members: members, query: query, group: group)}
  end

  def render(assigns) do
    ~H"""
    <.form
      :let={f}
      for={:search_form}
      phx-change="filter"
      phx-no-submit
      autocomplete={:off}
      onkeydown="return event.key != 'Enter';"
      class="flex flex-col sm:flex-row sm:items-center gap-4 pb-4 pt-2 lg:pt-0"
    >
      <div class="flex flex-row items-baseline justify-between w-full sm:flex-col mr-auto">
        <span class="text-2xl font-bold ">Medlemmar</span>
        <span class="text-sm text-gray-600">Visar <%= length(@members) %></span>
      </div>
      <%= text_input(f, :q,
        value: @query,
        phx_debounce: 500,
        placeholder: "Sök",
        class: "rounded-full text-sm h-10"
      ) %>
      <%= select(f, :group, @groups,
        class: "rounded-full text-sm h-10",
        value: @group,
        prompt: "Alla grupper"
      ) %>
    </.form>

    <table class="w-full text-sm text-left">
      <thead class="text-xs text-gray-700 uppercase">
        <tr class="border-b-2">
          <th scope="col" class="py-3 pl-2 pr-6">
            Namn
          </th>
          <th scope="col" class="py-3 px-2">
            KTH-id
          </th>
          <th scope="col" class="hidden sm:table-cell py-3 pr-6">
            Grupper
          </th>
        </tr>
      </thead>

      <tbody>
        <%= for {member, row} <- Enum.with_index(@members) do %>
          <.user_row even={if rem(row, 2) == 0, do: true, else: false} user={member} />
        <% end %>
      </tbody>
    </table>
    """
  end

  defp user_row(assigns) do
    ~H"""
    <tr class="hover:bg-gray-50 rounded-full border-b-[1px]">
      <td scope="row" class="py-4 pl-2 pr-6 font-medium text-gray-900 whitespace-nowrap">
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
              <%= "#{@user.first_name} #{@user.last_name}" %>
            </span>
          </.link>
        </div>
      </td>
      <td scope="row" class="p-2 font-medium text-gray-900 whitespace-nowrap ">
        <%= @user.username %>
      </td>
      <td class="hidden sm:table-cell">
        <div class="flex flex-row items-center space-x-1">
          <%= for group <- @user.group_memberships do %>
            <.link navigate={Routes.group_path(Endpoint, :group, group.show_group.id)}>
              <div
                class="px-2 py-0.5 rounded-full filter hover:brightness-90"
                style={"background-color: #{get_color(:bg, group.show_group.group.id)};
                      color: #{get_color(:text, group.show_group.group.id)};"}
              >
                <%= group.show_group.group.name %>
              </div>
            </.link>
          <% end %>
        </div>
      </td>
    </tr>
    """
  end

  @colors ~w"#8dd3c7 #ffffb3 #bebada #fb8072 #80b1d3 #fdb462 #b3de69 #fccde5 #d9d9d9 #bc80bd #ccebc5 #ffed6f"
  @text_colors ~w"#000 #000 #000 #fff #000 #fff #000 #000 #000 #fff #000 #000"

  defp get_color(:bg, index), do: Enum.at(@colors, rem(index - 1, 12), "#4e79a7")
  defp get_color(:text, index), do: Enum.at(@text_colors, rem(index - 1, 12), "#000")
end
