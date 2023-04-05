defmodule HajWeb.SettingsLive.User.Index do
  use HajWeb, :live_view

  alias Phoenix.HTML.Safe.Phoenix.LiveView
  alias Haj.Accounts

  @impl true
  def mount(_params, _session, socket) do
    login_secret = Application.get_env(:haj, :api_login_secret)

    {:ok,
     assign(
       socket,
       query: nil,
       role: nil,
       users: Accounts.list_users(),
       roles: [{"Admin", :admin}, {"Chef", :chef}, {"Spexare", :spexare}, {"Ingen", :none}],
       login_secret: login_secret
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera användare")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Alla användare")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("filter", %{"search" => query, "filter" => filter}, socket) do
    {:noreply, assign(socket, query: query, role: filter) |> fetch_users()}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, fetch_users(socket)}
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.User.FormComponent, {:saved, _}}, socket) do
    {:noreply, fetch_users(socket)}
  end

  defp fetch_users(socket) do
    filter = socket.assigns.role
    query = socket.assigns.query

    users =
      case query do
        "" ->
          Accounts.list_users()

        q ->
          Accounts.search_users(q)
      end
      |> Enum.filter(fn user -> filter == "" || user.role == String.to_existing_atom(filter) end)

    assign(socket, users: users)
  end
end
