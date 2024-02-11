defmodule HajWeb.SettingsLive.Form.FormComponent do
  use HajWeb, :live_component

  alias Haj.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Redigera formulär.</:subtitle>
      </.header>

      <.simple_form
        for={@client_form}
        id="form-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@client_form[:name]} type="text" label="Namn" />
        <.input field={@client_form[:description]} type="text" label="Beskrivning" />

        <HajWeb.CoreComponents.label>Frågor</HajWeb.CoreComponents.label>
        <.inputs_for :let={f_nested} field={@client_form[:questions]}>
          <div class="rounded-md border px-4 py-6">
            <input type="hidden" name="form[questions_sort][]" value={f_nested.index} />
            <div class="grid grid-cols-6 gap-2">
              <.input field={f_nested[:name]} type="text" label="Fråga" class="col-span-4" />
              <.input
                class="col-span-2"
                field={f_nested[:type]}
                type="select"
                label="Frågetyp"
                options={[
                  {"Text", :text},
                  {"Lång text", :text_area},
                  {"Val", :select},
                  {"Flerval", :multi_select}
                ]}
              />
              <.input
                field={f_nested[:description]}
                type="text"
                label="Beskrivning"
                class="col-span-6"
              />

              <div :if={is_select(f_nested[:type])} class="col-span-6">
                <HajWeb.CoreComponents.label>Alternativ</HajWeb.CoreComponents.label>
                <div :for={option <- f_nested[:options].value} class="flex flex-row items-center">
                  <.input
                    class="w-full"
                    type="text"
                    name={"form[questions][#{f_nested.index}][options][]"}
                    value={option}
                  />
                  <button
                    class="mt-2 ml-2"
                    name={"form[questions][#{f_nested.index}][options_drop][]"}
                    value={option}
                    phx-click={JS.dispatch("change")}
                    type="button"
                  >
                    <.icon name={:x_mark} class="h-6 w-6" />
                  </button>
                </div>
                <button
                  name={"form[questions][#{f_nested.index}][options_sort][]"}
                  value="new"
                  phx-click={JS.dispatch("change")}
                  type="button"
                  class="mt-3 flex flex-row items-center gap-2 text-sm text-zinc-600"
                >
                  <.icon name={:plus_circle} class="h-5 w-5" /> Nytt alternativ
                </button>
              </div>

              <div class="col-span-6 mt-2 flex flex-row items-center justify-end divide-x divide-solid">
                <.input field={f_nested[:required]} type="checkbox" label="Obligatorisk" class="px-2" />
                <button
                  name="form[questions_drop][]"
                  value={f_nested.index}
                  phx-click={JS.dispatch("change")}
                  type="button"
                  class="px-2"
                >
                  <.icon name={:trash} class="h-5 w-5 text-gray-900" solid />
                </button>
              </div>
            </div>
          </div>
        </.inputs_for>

        <button
          type="button"
          class="flex flex-row items-center gap-2 text-sm text-zinc-600"
          phx-target={@myself}
          name="form[questions_sort][]"
          value="new"
          phx-click={JS.dispatch("change")}
        >
          <.icon name={:plus_circle} class="h-5 w-5" /> Ny fråga
        </button>

        <:actions>
          <.button phx-disable-with="Sparar...">Spara formulär</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{form: form} = assigns, socket) do
    changeset = Forms.change_form(form)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"form" => form_params}, socket) do
    params =
      form_params
      |> merge_options()
      |> dbg()

    changeset =
      socket.assigns.form
      |> Forms.change_form(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"form" => form_params}, socket) do
    save_form(socket, socket.assigns.action, form_params)
  end

  defp save_form(socket, :edit, form_params) do
    case Forms.update_form(socket.assigns.form, merge_options(form_params)) do
      {:ok, form} ->
        notify_parent({:saved, form})

        {:noreply,
         socket
         |> put_flash(:info, "Form updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_form(socket, :new, form_params) do
    case Forms.create_form(form_params) do
      {:ok, form} ->
        notify_parent({:saved, form})

        {:noreply,
         socket
         |> put_flash(:info, "Form created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form =
      to_form(changeset)
      |> IO.inspect(label: "assign_form")

    assign(socket, :client_form, form)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp is_select(form_field) do
    form_field.value == "select" || form_field.value == "multi_select" ||
      form_field.value == :select || form_field.value == :multi_select
  end

  defp merge_options(form_params) do
    if form_params["questions"] do
      Map.update!(
        form_params,
        "questions",
        fn qs ->
          Enum.map(qs, &replace_options/1)
          |> Enum.into(%{})
        end
      )
    else
      form_params
    end
  end

  defp replace_options({index, question}) do
    drop = question["options_drop"] || []
    sort = question["options_sort"] || []

    question =
      Map.update(
        question,
        "options",
        [],
        fn options ->
          options
          |> Enum.reject(fn option -> option in drop end)
          |> Enum.map(fn option ->
            if option == "" do
              nil
            else
              option
            end
          end)
        end
      )

    question =
      case sort do
        ["new" | _] -> Map.update!(question, "options", fn o -> o ++ [nil] end)
        _ -> question
      end

    {index, question}
  end
end
