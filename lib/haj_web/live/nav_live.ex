defmodule HajWeb.Nav do
  use HajWeb, :component

  alias HajWeb.UserLive
  alias HajWeb.GroupLive
  alias HajWeb.GroupsLive
  alias HajWeb.MembersLive
  alias HajWeb.DashboardLive

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> Phoenix.LiveView.attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {DashboardLive.Index, _} ->
          :dashboard

        {MembersLive, _} ->
          :members

        {UserLive, _} ->
          :members

        {GroupsLive, _} ->
          :groups

        {GroupLive, _} ->
          {:group, String.to_integer(params["show_group_id"])}

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
