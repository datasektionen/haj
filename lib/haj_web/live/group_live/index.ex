defmodule HajWeb.GroupLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias HajWeb.Endpoint
  alias Haj.Policy

  def mount(%{"show_group_id" => show_group_id}, _session, socket) do
    show_group = Spex.get_show_group!(show_group_id)

    authorized = Policy.authorize?(:show_group_edit, socket.assigns.current_user, show_group)

    {:ok,
     assign(socket, page_title: show_group.group.name, group: show_group, authorized: authorized)}
  end

  defp chefer(show_group) do
    Enum.filter(show_group.group_memberships, fn %{role: role} -> role == :chef end)
    |> Enum.map(fn %{user: user} ->
      user
    end)
  end
end
