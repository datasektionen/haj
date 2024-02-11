defmodule HajWeb.EventLive.FormComponent do
  use HajWeb, :live_component
  alias Haj.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@response_form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <.form_input
          :for={question <- @form.questions}
          question={question}
          field={@response_form[String.to_atom("#{question.id}")]}
        />

        <.button phx-disable-with="Sparar...">Spara</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{event: event} = assigns, socket) do
    changeset = Forms.get_form_changeset!(event.form_id, %{})
    form = Forms.get_form!(event.form_id)

    {:ok, assign(socket, assigns) |> assign(form: form) |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"form_response" => response}, socket) do
    # We need to flatten all multi-responses to a list
    response = flatten_response(response)

    changeset =
      Forms.get_form_changeset!(socket.assigns.form.id, response) |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"form_response" => response}, socket) do
    response = flatten_response(response)

    case Forms.submit_form(socket.assigns.form.id, socket.assigns.current_user.id, response) do
      {:ok, _} ->
        push_flash(:info, "Skickade svar")
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp flatten_response(response) do
    Enum.reduce(response, response, fn {q, a}, acc ->
      case a do
        a when is_map(a) ->
          list = Map.filter(a, fn {_, sel} -> sel == "true" end) |> Map.keys()
          Map.put(acc, q, list)

        _ ->
          acc
      end
    end)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :response_form, to_form(changeset, as: :form_response))
  end
end
