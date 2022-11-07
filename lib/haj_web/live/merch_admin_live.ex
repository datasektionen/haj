defmodule HajWeb.MerchAdminLive do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Merch

  def mount(_params, _session, socket) do
    show = Spex.current_spex()

    show_options =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year, title: title} ->
        [key: "#{year.year}: #{title}", value: id]
      end)

    merch_items = Merch.list_merch_items_for_show(show.id)
    changesets = merch_items |> Enum.map(&Merch.change_merch_item/1)

    socket =
      socket
      |> assign(
        show: show,
        show_options: show_options,
        changesets: changesets
      )
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg),
        max_entries: 1,
        external: &presign_upload/2
      )

    {:ok, socket}
  end

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "metaspexet-haj"
    key = "/images/merch/#{entry.client_name}"

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

    dbg(meta)
    {:ok, meta, socket}
  end

  def handle_event("select_show", %{"show" => %{"show" => show_id}}, socket) do
    show = Spex.get_show!(show_id)
    merch_items = Merch.list_merch_items_for_show(show.id)
    changesets = merch_items |> Enum.map(&Merch.change_merch_item/1)

    {:noreply, assign(socket, show: show, changesets: changesets)}
  end

  def handle_event("validate_merch", %{"merch_item" => merch_params}, socket) do
    case merch_params["id"] do
      "" ->
        # New item, only has temp_id
        temp_id = merch_params["temp_id"]

        changeset =
          %Merch.MerchItem{temp_id: temp_id}
          |> Merch.change_merch_item(merch_params |> split_merch_comma_separated())
          |> Map.put(:action, :insert)

        changesets =
          Enum.map(socket.assigns.changesets, fn old ->
            case old.data.temp_id == temp_id do
              true -> changeset
              false -> old
            end
          end)

        {:noreply, assign(socket, changesets: changesets)}

      string_id ->
        # Normal already existing item
        id = string_id |> String.to_integer()

        changeset =
          %Merch.MerchItem{id: id}
          |> Merch.change_merch_item(merch_params |> split_merch_comma_separated())
          |> Map.put(:action, :insert)

        changesets =
          Enum.map(socket.assigns.changesets, fn old ->
            case old.data.id == id do
              true -> changeset
              false -> old
            end
          end)

        {:noreply, assign(socket, changesets: changesets)}
    end
  end

  def handle_event("save_merch", %{"merch_item" => merch_params}, socket) do
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

  def handle_event("remove_merch", %{"value" => temp_id}, socket) do
    changesets =
      Enum.filter(socket.assigns.changesets, fn changeset ->
        changeset.data.temp_id != temp_id
      end)

    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_event("delete_merch", %{"value" => id}, socket) do
    merch_item = Merch.get_merch_item!(id)

    case Merch.delete_merch_item(merch_item) do
      {:ok, _merch} ->
        changesets =
          Enum.filter(socket.assigns.changesets, fn changeset ->
            changeset.data.id != merch_item.id
          end)

        {:noreply, assign(socket, changesets: changesets)}

      {:error, %Ecto.Changeset{} = changeset} ->
        changesets =
          Enum.map(socket.assigns.changesets, fn old ->
            case old.data.id == changeset.data.id do
              true -> changeset
              false -> old
            end
          end)

        {:noreply,
         socket
         |> put_flash(:error, "Något gick fel.")
         |> assign(changesets: changesets)}
    end
  end

  def handle_event("add_merch", _params, socket) do
    changeset = Merch.change_merch_item(%Merch.MerchItem{temp_id: get_temp_id()})

    {:noreply, assign(socket, changesets: [changeset | socket.assigns.changesets])}
  end

  defp update_merch(merch_params, socket) do
    merch_item = Merch.get_merch_item!(merch_params["id"])

    case Merch.update_merch_item(merch_item, merch_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Merch uppdaterades.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        changesets =
          Enum.map(socket.assigns.changesets, fn old ->
            case old.data.id == changeset.data.id do
              true -> changeset
              false -> old
            end
          end)

        {:noreply,
         socket
         |> put_flash(:error, "Något gick fel.")
         |> assign(changesets: changesets)}
    end
  end

  defp create_merch(merch_params, socket) do
    temp_id = merch_params["temp_id"]

    merch_params =
      merch_params
      |> Map.put("show_id", socket.assigns.show.id)

    case Merch.create_merch_item(merch_params, &consume_images(socket, &1)) do
      {:ok, item} ->
        # Delete the temporary one with the created item
        changesets =
          Enum.map(socket.assigns.changesets, fn changeset ->
            case changeset.data.temp_id == temp_id do
              true -> Merch.change_merch_item(item)
              false -> changeset
            end
          end)

        {:noreply,
         socket
         |> put_flash(:info, "Merch skapades.")
         |> assign(changesets: changesets)}

      {:error, %Ecto.Changeset{} = changeset} ->
        changesets =
          Enum.map(socket.assigns.changesets, fn old ->
            case old.data.temp_id == temp_id do
              true -> changeset
              false -> old
            end
          end)

        {:noreply,
         socket
         |> put_flash(:error, "Något gick fel.")
         |> assign(changesets: changesets)}
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

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  # Makes the comma seperated string sizes in merch params to array
  defp split_merch_comma_separated(merch_params) do
    Map.update(merch_params, "sizes", [], fn str -> String.split(str, ",", trim: true) end)
  end

  def render(assigns) do
    ~H"""
    <div class="pb-4 border-b">
      <h3 class="font-bold text-2xl py-2">Administrera merch</h3>
      <.form :let={f} for={:show} phx-change="select_show" class="">
        <div class="">
          <%= label(f, :show, "Välj spex", class: "input-label") %>
          <div class="flex flex-row gap-4">
            <%= select(f, :show, @show_options, class: "input") %>
            <div class="flex justify-end mt-1 flex-shrink-0">
              <button
                type="button"
                class="h-full rounded-md border border-transparent py-2 px-4 bg-burgandy-500 text-sm font-medium text-white shadow-sm
                hover:bg-burgandy-600 focus:outline-none focus:ring-2 focus:ring-burgandy-500 focus:ring-offset-2"
                phx-click="add_merch"
              >
                Ny merch
              </button>
            </div>
          </div>
        </div>
      </.form>
    </div>

    <div class="grid gap-6 pt-4 lg:grid-cols-2">
      <%= for changeset <- @changesets do %>
        <.form
          :let={f}
          for={changeset}
          id={"merch_item_#{changeset.data.id}_#{changeset.data.temp_id}"}
          phx-change="validate_merch"
          phx-submit="save_merch"
          class="flex flex-col gap-4 bg-gray-50 py-4 px-4 rounded-lg border"
        >
          <%= hidden_input(f, :id) %>
          <%= hidden_input(f, :temp_id) %>

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

          <img src={Imgproxy.new(f.data.image) |> Imgproxy.resize(100, 100)} />
          <.live_file_input upload={@uploads.image} />

          <div>
            <%= label(f, "Pris (kr)", class: "input-label") %>
            <%= number_input(f, :price, class: "input") %>
            <%= error_tag(f, :price) %>
          </div>

          <div>
            <%= label(f, "Storlekar, fyll i som kommaseparerat", class: "input-label") %>
            <%= text_input(f, :sizes,
              value: (Ecto.Changeset.get_field(changeset, :sizes, []) || []) |> Enum.join(","),
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
                phx-click="delete_merch"
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
                phx-click="remove_merch"
                phx-no-sub
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
      <% end %>
    </div>
    """
  end
end
