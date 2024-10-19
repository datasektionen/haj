defmodule HajWeb.SettingsLive.Event.FormComponent do
  use HajWeb, :live_component

  alias Haj.Events
  alias Haj.Events.Event

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <.header>
          <%= @title %>
          <:subtitle>Redigera event.</:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="event-form"
          phx-target={@myself}
          phx-submit="save"
          phx-change="validate"
        >
          <.input field={@form[:name]} type="text" label="Namn" />
          <.input field={@form[:description]} type="textarea" label="Beskrivning" />
          <.input field={@form[:ticket_limit]} type="number" label="Biljettgräns" />
          <.input field={@form[:event_date]} type="datetime-local" label="Datum" />
          <.input field={@form[:purchase_deadline]} type="datetime-local" label="Köpdeadline" />
          <!-- File upload -->
          <div>
            <HajWeb.CoreComponents.label for="file">
              Bild
            </HajWeb.CoreComponents.label>
            <div class="mt-1">
              <.live_file_input upload={@uploads.file} />
            </div>
            <%= for entry <- @uploads.file.entries do %>
              <article class="upload-entry">
                <figure class="max-h-64 overflow-hidden rounded-md">
                  <.live_img_preview entry={entry} />
                  <figcaption><%= entry.client_name %></figcaption>
                </figure>

                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  phx-target={@myself}
                  aria-label="cancel"
                >
                  &times;
                </button>

                <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                <%= for err <- upload_errors(@uploads.file, entry) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              </article>
            <% end %>
          </div>

          <.input
            field={@form[:has_tickets]}
            type="checkbox"
            label="Har biljetter (don't use, experimental)"
            disabled
          />

          <.live_component
            id="search-component"
            module={HajWeb.Components.SearchComboboxComponent}
            search_fn={&Haj.Forms.search_forms/1}
            all_fn={&Haj.Forms.list_forms/0}
            field={@form[:form_id]}
            label="Formulär"
            chosen={@form[:form_id].value}
            placeholder={
              Ecto.assoc_loaded?(@form.data.form) && @form[:form].value && @form[:form].value.name
            }
          />

          <div :if={@form[:has_tickets].value} class="space-y-4">
            <h3 class="text-lg font-semibold leading-8 text-zinc-800">Biljettyper</h3>
            <.inputs_for :let={f_nested} field={@form[:ticket_types]}>
              <input type="hidden" name="event[tickets_sort][]" value={f_nested.index} />
              <div class="flex justify-between gap-2">
                <div class="w-1/4">
                  <.input field={f_nested[:name]} type="text" label="Namn" />
                </div>
                <div class="w-1/4">
                  <.input field={f_nested[:price]} type="number" label="Pris" />
                </div>
                <div class="w-1/2">
                  <.input field={f_nested[:description]} type="text" label="Beskrivning" />
                </div>
                <div>
                  <div class="h-[32px]" />
                  <button
                    name="event[tickets_drop][]"
                    value={f_nested.index}
                    phx-click={JS.dispatch("change")}
                    type="button"
                  >
                    <.icon name={:x_mark} class="relative top-2 h-6 w-6" />
                  </button>
                </div>
              </div>
            </.inputs_for>

            <input type="hidden" name="event[tickets_drop][]" />

            <div class="flex justify-start">
              <button
                type="button"
                class="flex flex-row items-center gap-2 text-sm text-zinc-600"
                phx-target={@myself}
                name="event[tickets_sort][]"
                value="new"
                phx-click={JS.dispatch("change")}
              >
                <.icon name={:plus_circle} class="h-5 w-5" /> Ny biljettyp
              </button>
            </div>
          </div>

          <:actions>
            <.button phx-disable-with="Saving...">Spara event</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{event: event} = assigns, socket) do
    changeset = Events.change_event(event)

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:file,
       accept: ~w(.jpg .jpeg),
       max_file_size: 8_000_000,
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Events.change_event(event_params, with_tickets: true)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"event" => event_params}, socket) do
    event_params = put_image_url(event_params, socket)

    save_event(socket, socket.assigns.action, event_params)
  end

  @impl true
  def handle_event("delete", %{"ticket" => ticket_type}, socket) do
    delete_ticket_type(socket, ticket_type)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp save_event(socket, :edit, event_params) do
    case Events.update_event(socket.assigns.event, event_params, &consume_images(socket, &1),
           with_tickets: true
         ) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(event_params, &consume_images(socket, &1), with_tickets: true) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp delete_ticket_type(socket, ticket_type) do
    case Events.delete_ticket_type(ticket_type) do
      {:ok, _ticket_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticket type deleted successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp put_image_url(params, socket) do
    {completed, []} = uploaded_entries(socket, :file)

    paths =
      for entry <- completed do
        "/images/events/#{entry.client_name}"
      end

    case paths do
      [] -> params
      [path | _] -> Map.put(params, "image", path)
    end
  end

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "metaspexet-haj"
    key = "images/events/#{entry.client_name}"

    config = %{
      region: "eu-north-1",
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads[entry.upload_config].max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{
      uploader: "S3",
      key: key,
      url: Haj.S3.base_url(),
      fields: fields
    }

    {:ok, meta, socket}
  end

  defp consume_images(socket, %Event{} = event) do
    consume_uploaded_entries(socket, :file, fn _meta, _entry -> :ok end)

    {:ok, event}
  end

  defp error_to_string(:too_large), do: "Too large, max size is 8MB"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(other), do: other
end
