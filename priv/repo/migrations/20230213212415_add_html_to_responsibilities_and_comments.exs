defmodule Haj.Repo.Migrations.AddHtmlToResponsibilitiesAndComments do
  use Ecto.Migration

  def change do
    alter table(:responsibilities) do
      add :description_html, :text
    end

    alter table(:responsibility_comments) do
      add :text_html, :text
    end
  end
end
