defmodule HajWeb.Nav.ActiveTab do
  defmacro __using__(_opts) do
    quote do
      import HajWeb.Nav.ActiveTab

      @tabs []
      @before_compile HajWeb.Nav.ActiveTab
    end
  end

  defmacro tab(module, tab_val) do
    quote do
      @tabs [{HajWeb.unquote(module), unquote(tab_val)} | @tabs]
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def active_tab(view) do
        Enum.reduce_while(@tabs, nil, fn {mod, tab}, found ->
          case view == mod do
            true -> {:halt, tab}
            false -> {:cont, found}
          end
        end)
      end
    end
  end
end

defmodule HajWeb.Nav do
  use HajWeb, :component
  use HajWeb.Nav.ActiveTab

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

  # Small macros for setting tabs. Syntax: tab ModuleName, :active_tab, :expanded_tab
  tab DashboardLive.Index, :dashboard
  tab MembersLive, :members
  tab GroupLive.Index, :groups
  tab MerchLive.Index, :merch
  tab MerchAdminLive.Index, :merch_admin
  tab MerchAdminLive.Orders, :merch_orders
  tab ResponsibilityLive.Index, :responsibilities
  tab ResponsibilityLive.History, :responsibility_history
  tab SongLive.Index, :songs
  tab SongLive.Show, :songs
  tab ShowLive.Index, :shows
  tab ApplicationsLive.Index, :applications

  tab SettingsLive.Index, :settings
  tab SettingsLive.User.Index, {:setting, :users}
  tab SettingsLive.Show.Index, {:setting, :shows}
  tab SettingsLive.Group.Index, {:setting, :groups}
  tab SettingsLive.Responsibility.Index, {:setting, :responsibilities}
  tab SettingsLive.Food.Index, {:setting, :foods}
  tab SettingsLive.Event.Index, {:setting, :events}
  tab SettingsLive.Form.Index, {:setting, :forms}

  tab EventLive.Index, :events

  defp set_active_tab(params, _url, socket) do
    active_tab =
      case socket.view do
        HajWeb.GroupLive.Show ->
          {:group, String.to_integer(params["show_group_id"])}

        HajWeb.GroupLive.Admin ->
          {:group, String.to_integer(params["show_group_id"])}

        _ ->
          active_tab(socket.view)
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
