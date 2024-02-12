defmodule HajWeb.GroupLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, _session, socket) do
    %{id: show_id} = Spex.current_spex()
    groups = Spex.get_show_groups_for_show(show_id)

    {:ok, assign(socket, page_title: "Grupper", groups: groups)}
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
