defmodule HajWeb.MembersLive do
  use HajWeb, :live_view

  alias Haj.Spex
  import HajWeb.LiveComponents.Table

  def mount(_params, _session, socket) do
    members = Spex.get_current_members()

    {:ok, socket |> assign(:members, members)}
  end

  def render(assigns) do
    ~H"""
    <.table rows={@members}>
      <:col let={member} label="Namn">
        <%= link "#{member.first_name} #{member.last_name}", to: Routes.user_path(HajWeb.Endpoint, :user, member.username)%>
      </:col>
      <:col let={member} label="KTH-id">
        <%= member.username %>
      </:col>
      <:col let={member} label="Email">
        <%= member.email %>
      </:col>
    </.table>
    """
  end
end
