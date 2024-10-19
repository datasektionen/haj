defmodule HajWeb.SettingsLive.Form.Index do
  use HajWeb, :live_view

  alias Haj.Forms
  alias Haj.Forms.Form

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      Formulär
      <:actions>
        <.link patch={~p"/settings/forms/new"}>
          <.button>Nytt formulär</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="forms"
      rows={@streams.forms}
      row_click={fn {_id, form} -> JS.navigate(~p"/settings/forms/#{form}/responses") end}
    >
      <:col :let={{_id, form}} label="Namn"><%= form.name %></:col>
      <:col :let={{_id, form}} label="Beskrivning"><%= form.description %></:col>
      <:action :let={{_id, form}}>
        <.link patch={~p"/settings/forms/#{form}/edit"}>Redigera</.link>
      </:action>
      <:action :let={{id, form}}>
        <.link
          phx-click={JS.push("delete", value: %{id: form.id}) |> hide("##{id}")}
          data-confirm="Är du säker, alla formulärsvar kommer försvinna!?"
        >
          Radera
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="form-modal"
      show
      on_cancel={JS.navigate(~p"/settings/forms")}
    >
      <.live_component
        module={HajWeb.SettingsLive.Form.FormComponent}
        id={@form.id || :new}
        title={@page_title}
        action={@live_action}
        form={@form}
        patch={~p"/settings/forms"}
      />
    </.modal>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :forms, Forms.list_forms())}
  end

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    form = Forms.get_form!(id)

    case Forms.delete_form(form) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :forms, form)}

      {:error, _} ->
        put_flash(socket, :error, "Kunde inte ta bort formuläret")
        {:noreply, socket}
    end
  end
end
