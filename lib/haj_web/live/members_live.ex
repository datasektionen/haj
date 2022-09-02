defmodule HajWeb.MembersLive do
  use HajWeb, :live_view

  alias Haj.Spex
  import HajWeb.LiveComponents.Table

  def mount(_params, %{"user_token" => token}, socket) do
    members = Spex.get_current_members()

    socket =
      socket
      |> assign(:members, members)
      |> assign(:title, "Medlemmar")
      |> assign_new(:current_user, fn -> Haj.Accounts.get_user_by_session_token(token) end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.table rows={@members}>
      <:col let={member} label="Namn">
        <%= link "#{member.first_name} #{member.last_name}", to: Routes.user_path(HajWeb.Endpoint, :index, member.username)%>
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
