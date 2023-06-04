defmodule HajWeb.ResponsibilityLive.Index do
  use HajWeb, :live_view

  alias Haj.Responsibilities
  alias Haj.Responsibilities.Responsibility

  on_mount {HajWeb.UserAuth, {:authorize, :responsibility_read}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :responsibilities, list_responsibilities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Responsibility")
    |> assign(:responsibility, Responsibilities.get_responsibility!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Responsibility")
    |> assign(:responsibility, %Responsibility{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Responsibilities")
    |> assign(:responsibility, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    responsibility = Responsibilities.get_responsibility!(id)
    {:ok, _} = Responsibilities.delete_responsibility(responsibility)

    {:noreply, assign(socket, :responsibilities, list_responsibilities())}
  end

  defp list_responsibilities do
    Responsibilities.list_responsibilities()
  end
end
