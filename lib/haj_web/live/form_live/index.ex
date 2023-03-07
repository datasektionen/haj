defmodule HajWeb.FormLive.Index do
  alias Haj.Forms
  use HajWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    changeset = Forms.get_form_changeset!(id, %{})
    form = Forms.get_form!(id)
    {:ok, assign(socket, form: form) |> assign_form(changeset)}
  end

  def handle_event("validate", %{"form_response" => response}, socket) do
    # We need to flatten all mult-responses to a list
    response =
      Enum.reduce(response, response, fn {q, a}, acc ->
        case a do
          a when is_map(a) ->
            list = Map.filter(a, fn {_, sel} -> sel == "true" end) |> Map.keys()
            Map.put(acc, q, list)

          _ ->
            acc
        end
      end)

    changeset =
      Forms.get_form_changeset!(socket.assigns.form.id, response) |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"form_response" => response}, socket) do
    # We need to flatten all mult-responses to a list
    response =
      Enum.reduce(response, response, fn {q, a}, acc ->
        case a do
          a when is_map(a) ->
            list = Map.filter(a, fn {_, sel} -> sel == "true" end) |> Map.keys()
            Map.put(acc, q, list)

          _ ->
            acc
        end
      end)

    case Forms.submit_form(socket.assigns.form.id, socket.assigns.current_user.id, response) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Skickade svar")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  attr :question, :any, required: true
  attr :field, :any, required: true

  defp form_input(%{question: %{type: :select}} = assigns) do
    ~H"""
    <.input field={@field} type="select" options={@question.options} label={@question.name} />
    """
  end

  defp form_input(%{question: %{type: :multi_select}} = assigns) do
    ~H"""
    <label class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= @question.name %>
    </label>
    <div :for={option <- @question.options}>
      <.input
        name={"#{@field.name}[#{option}]"}
        type="checkbox"
        value={option in Ecto.Changeset.get_field(assigns.field.form.source, assigns.field.field, [])}
        label={option}
      />
    </div>
    """
  end

  defp form_input(assigns) do
    ~H"""
    <.input field={@field} type="text" label={@question.name} />
    """
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :response_form, to_form(changeset, as: :form_response))
  end
end
