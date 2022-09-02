defmodule HajWeb.GroupsLive do
  use HajWeb, :live_view

  alias Haj.Spex
  import HajWeb.LiveComponents.Table

  def mount(_params, _session, socket) do
    groups = Spex.get_current_groups()

    {:ok, socket |> assign(:groups, groups) |> assign(:title, "Grupper")}
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
