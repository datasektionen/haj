defmodule HajWeb.SettingsLive.Responsibility.Show do
  use HajWeb, :live_view

  alias Haj.Repo
  alias Haj.Responsibilities

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, stream(socket, :responsible_users, Responsibilities.get_users_for_responsibility(id))}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:responsibility, Responsibilities.get_responsibility!(id))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket |> assign(:page_title, "Ansvar")
  end

  defp apply_action(socket, :edit, _params) do
    socket |> assign(:page_title, "Redigera ansvar")
  end

  defp apply_action(socket, :new_responsible, _params) do
    socket
    |> assign(:page_title, "Lägg till ansvarig")
    |> assign(:responsible_user, %Responsibilities.ResponsibleUser{
      responsibility_id: socket.assigns.responsibility
    })
  end

  @impl true
  def handle_event("remove_responsible_user", %{"id" => id}, socket) do
    responsible_user = Responsibilities.get_responsible_user!(id)

    {:ok, _} = Responsibilities.delete_responsible_user(responsible_user)

    {:noreply, stream_delete(socket, :responsible_users, responsible_user)}
  end

  @impl true
  def handle_info(
        {HajWeb.SettingsLive.Responsibility.ResponsibleUserFormComponent,
         {:saved, responsible_user}},
        socket
      ) do
    {:noreply,
     stream_insert(socket, :responsible_users, responsible_user |> Repo.preload([:show, :user]))}
  end

  @impl true
  def handle_info(
        {HajWeb.SettingsLive.Responsibility.FormComponent, {:saved, responsibility}},
        socket
      ) do
    {:noreply, socket |> assign(:responsibility, responsibility)}
  end
end
