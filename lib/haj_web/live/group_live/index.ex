defmodule HajWeb.GroupLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, _session, socket) do
    %{id: show_id} = Spex.current_spex()
    groups = Spex.get_show_groups_for_show(show_id)

    {:ok, assign(socket, page_title: "Grupper", groups: groups)}
  end

  defp group_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/group/#{@show_group.id}"}
      class="flex flex-col gap-1 rounded-lg border px-4 py-4 hover:bg-gray-50 sm:gap-1.5"
    >
      <div class="text-burgandy-500 text-lg font-bold">
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
