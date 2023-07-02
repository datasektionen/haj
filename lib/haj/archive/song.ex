defmodule Haj.Archive.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :name, :string
    field :number, :string
    field :original_name, :string
    field :text, :string
    field :file, :string
    field :line_timings, {:array, :integer}

    belongs_to :show, Haj.Spex.Show

    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:name, :original_name, :name, :number, :text, :show_id, :file, :line_timings])
    |> validate_required([:name, :original_name, :name, :number, :text])
  end
end
