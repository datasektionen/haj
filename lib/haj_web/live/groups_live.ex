defmodule HajWeb.GroupsLive do
  use HajWeb, :live_view

  alias HajWeb.Endpoint
  alias Haj.Spex

  def mount(_params, _session, socket) do
    %{id: show_id} = Spex.current_spex()
    groups = Spex.get_show_groups_for_show(show_id)

    {:ok, assign(socket, page_title: "Grupper", groups: groups)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row items-baseline justify-between w-full pt-4 sm:flex-col mr-auto">
        <span class="text-2xl font-bold ">Grupper</span>
        <span class="text-sm text-gray-600">Visar <%= length(@groups) %></span>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 pt-4">
        <%= for group <- @groups do %>
          <.group_card show_group={group} members={Enum.count(group.group_memberships)} />
        <% end %>
      </div>
    </div>
    """
  end

  defp group_card(assigns) do
    ~H"""
    <.link
      navigate={Routes.group_path(Endpoint, :index, @show_group.id)}
      class="flex flex-col gap-1 sm:gap-1.5 border rounded-lg px-4 py-4 hover:bg-gray-50"
    >
      <div class="text-lg font-bold text-burgandy-500">
        <%= @show_group.group.name %>
      </div>
      <div class="text-gray-500">
        <%= @members %> medlemmar
      </div>
      <div>
        <%= chefer(@show_group) %>
      </div>
    </.link>
    """
  end

  defp chefer(group) do
    chefer =
      Enum.filter(group.group_memberships, fn %{role: role} -> role == :chef end)
      |> Enum.map(fn %{user: user} -> full_name(user) end)

    case length(chefer) do
      0 -> "Inga chefer"
      1 -> "Chef: #{chef_string(chefer)}"
      _ -> "Chefer: #{chef_string(chefer)}"
    end
  end

  defp chef_string([a]), do: a
  defp chef_string([a, b]), do: "#{a} och #{b}"
  defp chef_string([a | rest]), do: "#{a}, #{chef_string(rest)}"
end
