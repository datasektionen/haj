defmodule HajWeb.FormLive.Index do
  alias Haj.Forms
  use HajWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    changeset = Forms.get_form_changeset!(id, %{})
    form = Forms.get_form!(id)
    {:ok, assign(socket, form: form) |> assign_form(changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mr-auto flex w-full flex-row items-baseline justify-between sm:flex-col">
        <span class="text-2xl font-bold">Formulär</span>
        <span class="text-sm text-gray-600">Här kan du fylla i formuläret: <%= @form.name %></span>
      </div>

      <div class="my-6">
        <h2 class="text-base font-semibold leading-7 text-gray-900">Beskrivning</h2>
        <p class="mt-1 text-sm leading-6 text-gray-600"><%= @form.description %></p>
      </div>
      <.form for={@response_form} phx-submit="save" phx-change="validate">
        <div class="border-gray-900/10 mt-4 grid grid-cols-1 gap-y-6 border-b pb-8 sm:grid-cols-6">
          <div :for={question <- @form.questions} class={styling_for_question(question)}>
            <.form_input question={question} field={@response_form[String.to_atom("#{question.id}")]} />
            <div :if={question.description} class="mt-2 text-sm text-gray-500">
              <%= question.description %>
            </div>
          </div>
        </div>
        <div class="mt-4 flex flex-row justify-end">
          <.button phx-disable-with="Sparar...">Spara</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"form_response" => response}, socket) do
    response = flatten_response(response)

    changeset =
      Forms.get_form_changeset!(socket.assigns.form.id, response) |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"form_response" => response}, socket) do
    response = flatten_response(response)

    case Forms.submit_form(socket.assigns.form.id, socket.assigns.current_user.id, response) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Skickade svar")}

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

  defp styling_for_question(%{type: :multi_select}), do: "sm:col-span-4"
  defp styling_for_question(%{type: :select}), do: "sm:col-span-3"
  defp styling_for_question(%{type: :text_area}), do: "sm:col-span-6"
  defp styling_for_question(%{type: :text}), do: "sm:col-span-4"
end
