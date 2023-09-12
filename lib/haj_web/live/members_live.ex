defmodule HajWeb.MembersLive do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, _session, socket) do
    %{id: show_id} = Spex.current_spex()

    members = Spex.list_members_for_show(show_id) |> Spex.preload_user_groups()

    groups =
      Spex.get_show_groups_for_show(show_id)
      |> Enum.map(fn %{id: id, group: g} -> [key: g.name, value: id] end)

    {:ok,
     assign(socket,
       page_title: "Medlemmar",
       show_id: show_id,
       query: nil,
       groups: groups,
       group: nil,
       members: members
     )}
  end

  def handle_event("filter", %{"search_form" => %{"q" => query, "group" => group}}, socket) do
    members =
      case {group, query} do
        {"", ""} ->
          Spex.list_members_for_show(socket.assigns.show_id)

        {group, ""} ->
          Spex.get_show_group_members(group)

        {"", query} ->
          Spex.search_show_members(socket.assigns.show_id, query)

        {group, query} ->
          Spex.search_group_members(group, query)
      end
      |> Spex.preload_user_groups()

    {:noreply, assign(socket, members: members, query: query, group: group)}
  end

  def render(assigns) do
    ~H"""
    <.form
      :let={f}
      for={%{}}
      as={:search_form}
      phx-change="filter"
      phx-no-submit
      autocomplete={:off}
      onkeydown="return event.key != 'Enter';"
      class="flex flex-col gap-4 pt-4 sm:flex-row sm:items-center"
    >
      <div class="mr-auto flex w-full flex-row items-baseline justify-between sm:flex-col">
        <span class="text-2xl font-bold">Medlemmar</span>
        <span class="text-sm text-gray-600">Visar <%= length(@members) %> personer</span>
      </div>
      <%= text_input(f, :q,
        value: @query,
        phx_debounce: 500,
        placeholder: "Sök",
        class: "h-10 rounded-full text-sm"
      ) %>
      <%= select(f, :group, @groups,
        class: "h-10 rounded-full text-sm",
        value: @group,
        prompt: "Alla grupper"
      ) %>
    </.form>

    <.live_table rows={@members}>
      <:col :let={member} label="Namn">
        <.user_card user={member} />
      </:col>
      <:col :let={member} label="KTH-id">
        <%= member.username %>
      </:col>
      <:col :let={member} label="Grupper" class="hidden sm:table-cell">
        <div class="flex flex-row items-center space-x-1">
          <%= for group <- member.group_memberships do %>
            <.link navigate={~p"/group/#{group.show_group_id}"}>
              <div
                class="rounded-full px-2 py-0.5 filter hover:brightness-90"
                style={"background-color: #{get_color(:bg, group.show_group.group.id)};
                      color: #{pick_text_color(get_color(:bg, group.show_group.group.id))};"}
              >
                <%= group.show_group.group.name %>
              </div>
            </.link>
          <% end %>
        </div>
      </:col>
    </.live_table>
    """
  end

  @colors ~w"#8dd3c7 #ffffb3 #bebada #fb8072 #80b1d3 #fdb462 #b3de69 #fccde5 #d9d9d9 #bc80bd #ccebc5 #ffed6f"

  defp get_color(:bg, index), do: Enum.at(@colors, rem(index - 1, 12), "#4e79a7")
end
