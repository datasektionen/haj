defmodule Haj.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add(:original_name, :string)
      add(:name, :string)
      add(:number, :string)
      add(:text, :text)
      add(:show_id, references(:shows, on_delete: :nothing))
      add(:file, :string)
      add(:line_timings, {:array, :integer})

      timestamps()
    end

    create(index(:songs, [:show_id]))
  end
end
