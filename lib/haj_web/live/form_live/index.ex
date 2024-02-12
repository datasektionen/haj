defmodule HajWeb.FormLive.Index do
  alias Haj.Forms
  use HajWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    changeset = Forms.get_form_changeset!(id, %{})
    form = Forms.get_form!(id)
    {:ok, assign(socket, form: form) |> assign_form(changeset)}
  end

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
end
