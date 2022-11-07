defmodule HajWeb.Components.MerchAdminForm do
  use HajWeb, :live_component

  alias Haj.Merch

  def mount(socket) do
    socket =
      socket
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg),
        max_entries: 1,
        external: &presign_upload/2
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"merch_item" => merch_params}, socket) do
    case merch_params["id"] do
      "" ->
        # New item, only has temp_id
        temp_id = merch_params["temp_id"]

        changeset =
          %Merch.MerchItem{temp_id: temp_id}
          |> Merch.change_merch_item(merch_params |> split_merch_comma_separated())
          |> Map.put(:action, :insert)

        send(self(), {:updated_changeset, :new, changeset})
        {:noreply, socket}

      string_id ->
        # Normal already existing item
        id = string_id |> String.to_integer()

        changeset =
          %Merch.MerchItem{id: id}
          |> Merch.change_merch_item(merch_params |> split_merch_comma_separated())
          |> Map.put(:action, :insert)

        send(self(), {:updated_changeset, :edit, changeset})

        {:noreply, socket}
    end
  end

  def handle_event("save", %{"merch_item" => merch_params}, socket) do
    merch_params =
      merch_params
      |> split_merch_comma_separated()
      |> put_image_url(socket)

    case merch_params["id"] do
      "" ->
        # No id so new item
        create_merch(merch_params, socket)

      _id ->
        # Update already existing item
        update_merch(merch_params, socket)
    end
  end

  def handle_event("remove", %{"value" => temp_id}, socket) do
    send(self(), {:removed_merch, temp_id})
    {:noreply, socket}
  end

  def handle_event("delete", %{"value" => id}, socket) do
    merch_item = Merch.get_merch_item!(id)

    case Merch.delete_merch_item(merch_item) do
      {:ok, _merch} ->
        send(self(), {:deleted_merch, merch_item.id})
        push_flash(:info, "Merch raderades.")
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        send(self(), {:updated_changeset, :edit, changeset})

        push_flash(:error, "Något gick fel.")
        {:noreply, socket}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp update_merch(merch_params, socket) do
    merch_item = Merch.get_merch_item!(merch_params["id"])

    case Merch.update_merch_item(merch_item, merch_params) do
      {:ok, item} ->
        changeset =
          Merch.change_merch_item(item)
          |> Map.put(:action, :insert)

        send(self(), {:updated_changeset, :edit, changeset})
        push_flash(:info, "Merch uppdaterades.")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        send(self(), {:updated_changeset, :edit, changeset})

        push_flash(:error, "Något gick fel.")
        {:noreply, socket}
    end
  end

  defp create_merch(merch_params, socket) do
    temp_id = merch_params["temp_id"]

    merch_params =
      merch_params
      |> Map.put("show_id", socket.assigns.show_id)

    case Merch.create_merch_item(merch_params, &consume_images(socket, &1)) do
      {:ok, item} ->
        send(self(), {:created_merch, item, temp_id})
        push_flash(:info, "Merch skapades.")
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        send(self(), {:updated_changeset, :new, changeset})
        push_flash(:error, "Något gick fel.")
        {:noreply, socket}
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
      url: "https://#{bucket}.s3-#{config.region}.amazonaws.com",
      fields: fields
    }

    {:ok, meta, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        id={"form_#{@changeset.data.id}_#{@changeset.data.temp_id}"}
        class="flex flex-col gap-4 bg-gray-50 py-4 px-4 rounded-lg border"
      >
        <%= hidden_input(f, :id) %>
        <%= hidden_input(f, :temp_id) %>
        <%= hidden_input(f, :image) %>

        <.image_upload_component
          f={f}
          uploads={@uploads}
          target={@myself}
          image={Ecto.Changeset.get_field(@changeset, :image)}
        />

        <div>
          <%= label(f, "Namn", class: "input-label") %>
          <%= text_input(f, :name, class: "input") %>
          <%= error_tag(f, :name) %>
        </div>

        <div>
          <%= label(f, "Beskrivning", class: "input-label") %>
          <%= textarea(f, :description, class: "input") %>
          <%= error_tag(f, :description) %>
        </div>

        <div>
          <%= label(f, "Pris (kr)", class: "input-label") %>
          <%= number_input(f, :price, class: "input") %>
          <%= error_tag(f, :price) %>
        </div>

        <div>
          <%= label(f, "Storlekar, fyll i som kommaseparerat", class: "input-label") %>
          <%= text_input(f, :sizes,
            value: (Ecto.Changeset.get_field(@changeset, :sizes, []) || []) |> Enum.join(","),
            class: "input"
          ) %>
          <%= error_tag(f, :sizes) %>
        </div>

        <div>
          <%= label(f, "Beställningsdeadline", class: "input-label") %>
          <%= datetime_local_input(f, :purchase_deadline, class: "input") %>
          <%= error_tag(f, :purchase_deadline) %>
        </div>

        <div class="flex items-center justify-end gap-2 pt-4">
          <%= if is_nil(f.data.temp_id) || !is_nil(f.data.id) do %>
            <button
              type="button"
              phx-click="delete"
              phx-target={@myself}
              value={f.data.id}
              class="inline-flex items-center rounded-md border border-transparent py-2 px-4 bg-red-700 text-sm font-medium text-white shadow-sm
                    hover:bg-red-800 focus:outline-none focus:ring-2 focus:ring-red-700 focus:ring-offset-2"
            >
              <.icon name={:trash} mini />
              <span>Radera</span>
            </button>
          <% else %>
            <button
              type="button"
              phx-click="remove"
              phx-target={@myself}
              value={f.data.temp_id}
              class="inline-flex items-center rounded-md border border-transparent py-2 px-4 bg-red-700 text-sm font-medium text-white shadow-sm
                    hover:bg-red-800 focus:outline-none focus:ring-2 focus:ring-red-700 focus:ring-offset-2"
            >
              <span>Ta bort</span>
            </button>
          <% end %>
          <%= submit("Spara",
            class:
              "inline-flex justify-center rounded-md border border-transparent py-2 px-4 bg-burgandy-500 text-sm font-medium text-white shadow-sm
                hover:bg-burgandy-600 focus:outline-none focus:ring-2 focus:ring-burgandy-500 focus:ring-offset-2"
          ) %>
        </div>
      </.form>
    </div>
    """
  end

  defp image_upload_component(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row gap-6">
      <%= for entry <- @uploads.image.entries do %>
        <article class="">
          <figure class="w-48 h-32 rounded-md overflow-hidden">
            <.live_img_preview entry={entry} />
          </figure>

          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            phx-target={@target}
            aria-label="cancel"
          >
            &times;
          </button>

          <%= for err <- upload_errors(@uploads.image, entry) do %>
            <p class="alert alert-danger"><%= err %></p>
          <% end %>
        </article>
      <% end %>

      <%= if @uploads.image.entries == [] do %>
        <article class="">
          <figure class="w-48 h-32 rounded-md overflow-hidden">
            <%= if @image do %>
              <img src={Imgproxy.new(@image) |> Imgproxy.resize(400, 400) |> to_string()} />
            <% else %>
              <div class="h-full w-full bg-white border rounded-md" />
            <% end %>
          </figure>
        </article>
      <% end %>

      <div>
        <label class="input-label">Ladda upp bild</label>
        <.live_file_input upload={@uploads.image} class="text-sm pt-2" />
      </div>
    </div>
    """
  end
end
