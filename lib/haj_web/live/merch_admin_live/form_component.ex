defmodule HajWeb.MerchAdminLive.FormComponent do
  use HajWeb, :live_component

  alias Haj.Merch

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="merch-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.image_upload_component {assigns} />
        <.input field={@form[:name]} label="Namn" type="text" />
        <.input field={@form[:description]} label="Beskrivning" type="textarea" />
        <.input field={@form[:price]} label="Pris (kr)" type="number" />
        <.input
          field={@form[:sizes]}
          label="Storlekar, fyll i som kommaseparerat"
          type="text"
          value={(input_value(@form, :sizes) || []) |> Enum.join(",")}
        />
        <%!-- For the input with datetime-local does not work properly. See issue: https://github.com/phoenixframework/phoenix/issues/5098 --%>
        <.input field={@form[:purchase_deadline]} type="datetime-local" label="Beställningsdeadline" />

        <:actions>
          <.button phx-disable-with="Sparar...">Spara</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{merch_item: merch_item} = assigns, socket) do
    changeset = Merch.change_merch_item(merch_item)

    {:ok,
     socket
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg),
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign(assigns)
     |> assign(:image, merch_item.image)
     |> assign_form(changeset)}
  end

  def handle_event("validate", %{"merch_item" => merch_params}, socket) do
    merch_params = merch_params |> split_merch_comma_separated()

    changeset =
      socket.assigns.merch_item
      |> Merch.change_merch_item(merch_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"merch_item" => merch_params}, socket) do
    merch_params =
      merch_params
      |> split_merch_comma_separated()
      |> put_image_url(socket)

    save_merch(socket, socket.assigns.action, merch_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp save_merch(socket, :edit, merch_params) do
    case Merch.update_merch_item(
           socket.assigns.merch_item,
           merch_params,
           &consume_images(socket, &1)
         ) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merch uppdaterades.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_merch(socket, :new, merch_params) do
    merch_params =
      merch_params
      |> Map.put("show_id", socket.assigns.show.id)

    case Merch.create_merch_item(merch_params, &consume_images(socket, &1)) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merch skapades.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp put_image_url(params, socket) do
    {completed, []} = uploaded_entries(socket, :image)

    paths =
      for entry <- completed do
        "/images/merch/#{entry.client_name}"
      end

    case paths do
      [] -> params
      [path | _] -> Map.put(params, "image", path)
    end
  end

  defp consume_images(socket, %Merch.MerchItem{} = merch) do
    consume_uploaded_entries(socket, :image, fn _meta, _entry -> :ok end)

    {:ok, merch}
  end

  # Makes the comma seperated string sizes in merch params to array
  defp split_merch_comma_separated(merch_params) do
    Map.update(merch_params, "sizes", [], fn str -> String.split(str, ",", trim: true) end)
  end

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "metaspexet-haj"
    key = "images/merch/#{entry.client_name}"

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

  defp image_upload_component(assigns) do
    ~H"""
    <div class="flex flex-col gap-6 md:flex-row">
      <%= for entry <- @uploads.image.entries do %>
        <article class="">
          <figure class="h-32 w-48 overflow-hidden rounded-md">
            <.live_img_preview :if={entry.valid?} entry={entry} />
            <div :if={!entry.valid?} class="h-full w-full rounded-md border bg-white" />
          </figure>

          <button
            :if={entry.valid?}
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            phx-target={@myself}
            aria-label="cancel"
          >
            &times;
          </button>

          <%= for err <- upload_errors(@uploads.image, entry) do %>
            <.error><%= err %></.error>
          <% end %>
        </article>
      <% end %>

      <%= if @uploads.image.entries == [] do %>
        <article class="">
          <figure class="h-32 w-48 overflow-hidden rounded-md">
            <%= if @image do %>
              <img src={image_url(@image, 400, 400)} />
            <% else %>
              <div class="h-full w-full rounded-md border bg-white" />
            <% end %>
          </figure>
        </article>
      <% end %>

      <div>
        <HajWeb.CoreComponents.label>Ladda upp bild</HajWeb.CoreComponents.label>
        <.live_file_input upload={@uploads.image} class="pt-2 text-sm" />
      </div>
    </div>
    """
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
