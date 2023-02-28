defmodule HajWeb.Nav do
  use HajWeb, :component

  alias HajWeb.UserLive
  alias HajWeb.GroupLive
  alias HajWeb.GroupsLive
  alias HajWeb.MembersLive
  alias HajWeb.DashboardLive
  alias HajWeb.SettingsLive

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign(expanded_tab: nil)
     |> Phoenix.LiveView.attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  def on_mount(:settings, _params, _session, socket) do
    {:cont,
     socket
     |> assign(expanded_tab: :settings)
     |> Phoenix.LiveView.attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {DashboardLive.Index, _} ->
          :dashboard

        {MembersLive, _} ->
          :members

        {GroupsLive, _} ->
          :groups

        {GroupLive, _} ->
          {:group, String.to_integer(params["show_group_id"])}

        {SettingsLive.Index, _} ->
          :settings

        {SettingsLive.Show.Index, _} ->
          {:setting, :shows}

        {SettingsLive.Group.Index, _} ->
          {:setting, :groups}

        {SettingsLive.Food.Index, _} ->
          {:setting, :foods}

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
