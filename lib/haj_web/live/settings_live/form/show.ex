defmodule HajWeb.SettingsLive.Form.Show do
  use HajWeb, :live_view

  alias Haj.Forms

  @impl true
  def mount(%{"id" => form_id}, _session, socket) do
    form = Forms.get_form!(form_id)
    responses = Forms.list_responses_for(form_id)

    {:ok, assign(socket, form: form) |> stream(:responses, responses)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    response = Forms.get_response!(id)

    case Forms.delete_response(response) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :responses, response)}

      {:error, _} ->
        put_flash(socket, :error, "Kunde inte ta bort svaret")
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Formulärsvar
      <:subtitle>Listar alla formulärsvar till formuläret: <%= @form.name %></:subtitle>
    </.header>

    <.table small id="food-users" rows={@streams.responses}>
      <:col :let={{_id, response}} label="Namn">
        <%= response.user.full_name %>
      </:col>
      <:col :let={{_id, response}} label="Tid">
        <%= format_date(response.inserted_at) %>
      </:col>

      <:action :let={{_id, response}}>
        <.link patch={~p"/settings/forms/#{@form}/responses/#{response}"}>
          Visa svar
        </.link>
      </:action>

      <:action :let={{id, response}}>
        <.link
          phx-click={JS.push("delete", value: %{id: response.id}) |> hide("##{id}")}
          data-confirm="Är du säker?"
        >
          Radera
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action == :response}
      id="form-modal"
      show
      on_cancel={JS.navigate(~p"/settings/forms/#{@form}/responses")}
    >
      <:title>Formulärsvar</:title>

      <div class="mt-6">
        <dl class="grid grid-cols-1 sm:grid-cols-2">
          <.field name="Person">
            <.user_card user={@response.user} />
          </.field>
          <.field name="Inskickad">
            <%= @response.updated_at %>
          </.field>

          <.field :for={qr <- @response.question_responses} large name={qr.question.name}>
            <%= qr %>
          </.field>
        </dl>
      </div>
    </.modal>
    """
  end

  defp apply_action(socket, :responses, %{"id" => id}) do
    socket
    |> assign(:page_title, "Alla formulärsvar")
    |> assign(:form, Forms.get_form!(id))
  end

  defp apply_action(socket, :response, %{"id" => id, "response_id" => response_id}) do
    response =
      Forms.get_response!(response_id)

    id = String.to_integer(id)

    if response.form_id == id do
      socket
      |> assign(:page_title, "Formulärsvar")
      |> assign(:form, Forms.get_form!(id))
      |> assign(:response, response)
    else
      socket
      |> put_flash(:error, "Formulärsvar tillhör inte formuläret")
      |> push_navigate(to: ~p"/settings/forms/#{id}/responses")
    end
  end

  attr :large, :boolean, default: false
  attr :top, :boolean, default: false
  attr :name, :string
  slot :inner_block

  defp field(assigns) do
    ~H"""
    <div class={[
      "px-4 py-6 sm:px-0 border-t border-gray-100",
      @large || "sm:col-span-1",
      @large && "sm:col-span-2"
    ]}>
      <dt class="text-sm font-medium leading-6 text-gray-900"><%= @name %></dt>
      <dd class="mt-1 text-sm leading-6 text-gray-700 sm:mt-2">
        <%= render_slot(@inner_block) %>
      </dd>
    </div>
    """
  end
end
