defmodule Haj.Repo.Migrations.AddUserApplicationFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :ths_member, :string
      add :gender, :string
    end
  end
end
