defmodule HajWeb.SettingsLive.Form.Index do
  use HajWeb, :live_view

  alias Haj.Forms
  alias Haj.Forms.Form

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :forms, Forms.list_forms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera formulär")
    |> assign(:form, Forms.get_form!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nytt formulär")
    |> assign(:form, %Form{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Formulär")
    |> assign(:form, nil)
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.Form.FormComponent, {:saved, form}}, socket) do
    {:noreply, stream_insert(socket, :forms, form)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    form = Forms.get_form!(id)
    {:ok, _} = Forms.delete_form(form)

    {:noreply, stream_delete(socket, :forms, form)}
  end
end
