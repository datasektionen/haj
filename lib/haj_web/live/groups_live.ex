defmodule HajWeb.GroupsLive do
  use HajWeb, :live_view

  alias Haj.Spex
  import HajWeb.LiveComponents.Table

  def mount(_params, %{"user_token" => token}, socket) do
    groups = Spex.get_current_groups()

    socket =
      socket
      |> assign(:groups, groups)
      |> assign(:title, "Grupper")
      |> assign_new(:current_user, fn -> Haj.Accounts.get_user_by_session_token(token) end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.table rows={@groups}>
      <:col let={group} label="Grupp">
        <%= link "#{group.group.name}", to: Routes.group_path(HajWeb.Endpoint, :index, group.group.name)%>
      </:col>
      <:col let={group} label="Antal medlemmar">
        <%= group.members %>
      </:col>
    </.table>
    """
  end
end
