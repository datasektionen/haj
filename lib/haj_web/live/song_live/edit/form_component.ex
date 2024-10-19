defmodule HajWeb.SongLive.Edit.FormComponent do
  use HajWeb, :live_component

  alias Haj.Archive
  alias Haj.Spex

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Använd detta formulär för att redigera sånger i databasen.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="song-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Namn" />
        <.input field={@form[:original_name]} type="text" label="Originalnamn" />
        <.input field={@form[:number]} type="text" label="Number (t.ex. 2.3)" />
        <.input field={@form[:text]} type="textarea" label="Låttext" />

        <label class="block text-sm font-semibold leading-6 text-zinc-800">
          Tidpunkter för låtrader, anges som en kommasparerad lista av millisekunder
        </label>
        <input
          type="text"
          name="song[line_timings]"
          value={@line_timings}
          class={[
            "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
            "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
            "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
            "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5"
          ]}
        />

        <.input
          field={@form[:show_id]}
          type="select"
          label="Spex"
          options={@show_options}
          prompt="Välj spex"
        />

        <div>
          <HajWeb.CoreComponents.label for="file">
            Fil
          </HajWeb.CoreComponents.label>
          <div class="mt-1">
            <.live_file_input upload={@uploads.file} />
          </div>
          <div :for={{_, err} <- @uploads.file.errors}>
            <.error><%= error_to_string(err) %></.error>
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Song</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{song: song} = assigns, socket) do
    changeset = Archive.change_song(song)

    line_timings = if song.line_timings, do: Enum.join(song.line_timings, ","), else: ""

    shows = Spex.list_shows()

    show_options = for show <- shows, do: {"#{show.year.year}: #{show.title}", show.id}

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:file,
       accept: [".mp4", ".mp3"],
       max_file_size: 20_000_000,
       max_entries: 1,
       external: &presign_upload/2
     )
     |> assign(assigns)
     |> assign(show_options: show_options, line_timings: line_timings)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    changeset =
      socket.assigns.song
      |> Archive.change_song(song_params)
      |> Map.put(:action, :validate)

    line_timings = song_params["line_timings"]

    {:noreply, assign(socket, line_timings: line_timings) |> assign_form(changeset)}
  end

  def handle_event("save", %{"song" => song_params}, socket) do
    song_params = put_song_url(song_params, socket)
    line_timings = parse_line_timings(song_params["line_timings"])

    song_params = Map.put(song_params, "line_timings", line_timings)

    save_song(socket, socket.assigns.action, song_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  defp save_song(socket, :edit, song_params) do
    case Archive.update_song(socket.assigns.song, song_params, &consume_songs(socket, &1)) do
      {:ok, song} ->
        notify_parent({:saved, song})

        {:noreply,
         socket
         |> put_flash(:info, "Song updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_song(socket, :new, song_params) do
    case Archive.create_song(song_params, &consume_songs(socket, &1)) do
      {:ok, song} ->
        notify_parent({:saved, song})

        {:noreply,
         socket
         |> put_flash(:info, "Song created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp presign_upload(entry, socket) do
    uploads = socket.assigns.uploads
    bucket = "metaspexet-haj"
    key = "archive/songs/#{entry.client_name}"

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

  defp put_song_url(params, socket) do
    {completed, []} = uploaded_entries(socket, :file)

    paths = for entry <- completed, do: "/archive/songs/#{entry.client_name}"

    case paths do
      [] -> params
      [path | _] -> Map.put(params, "file", path)
    end
  end

  defp consume_songs(socket, %Haj.Archive.Song{} = song) do
    consume_uploaded_entries(socket, :file, fn _meta, _entry -> :ok end)

    {:ok, song}
  end

  defp parse_line_timings(line_timings) do
    case line_timings
         |> String.trim() do
      "" ->
        []

      timings ->
        timings
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
    end
  end

  defp error_to_string(:too_large), do: "Too large, max size is 20MB"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(other), do: other
end
