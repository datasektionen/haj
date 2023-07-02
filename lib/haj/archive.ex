defmodule Haj.Archive do
  @moduledoc """
  The Archive context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Archive.Song

  @doc """
  Returns the list of songs.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs do
    Repo.all(Song)
  end

  def list_songs_for_show(show_id) do
    Repo.all(from s in Song, where: s.show_id == ^show_id, order_by: [asc: s.number])
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id), do: Repo.get!(Song, id)

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs \\ %{}, after_save \\ &{:ok, &1}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs, after_save \\ &{:ok, &1}) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  def search_songs(search_phrase, options \\ []) do
    include_rank = Keyword.get(options, :rank, false)

    base_query =
      from s in Song,
        where: fragment("? % ?", s.name, ^search_phrase),
        order_by: fragment("? % ?", s.name, ^search_phrase)

    query =
      if include_rank do
        from [s] in base_query,
          select: {s, fragment("similarity(?, ?)", s.name, ^search_phrase)}
      else
        base_query
      end

    Repo.all(query)
  end

  defp after_save({:ok, result}, func) do
    {:ok, _result} = func.(result)
  end

  defp after_save(error, _func), do: error

  def s3_url(path) do
    {:ok, url} =
      ExAws.Config.new(:s3, region: "eu-north-1")
      |> ExAws.S3.presigned_url(:get, "metaspexet-haj", path, virtual_host: true)

    url
  end
end
