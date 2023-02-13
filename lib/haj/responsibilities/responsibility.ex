defmodule Haj.Responsibilities.Responsibility do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responsibilities" do
    field :description, :string
    field :description_html, :string
    field :name, :string

    has_many :comments, Haj.Responsibilities.Comment
    has_many :responsible_users, Haj.Responsibilities.ResponsibleUser

    timestamps()
  end

  @doc false
  def changeset(responsibility, attrs) do
    responsibility
    |> cast(attrs, [:name, :description, :description_html])
    |> validate_required([:name, :description])
    |> gen_html_description()
  end

  defp gen_html_description(%{valid?: true, changes: %{description: text}} = changeset) do
    put_change(changeset, :description_html, Haj.Markdown.to_html!(text))
  end

  defp gen_html_description(changeset), do: changeset
end
