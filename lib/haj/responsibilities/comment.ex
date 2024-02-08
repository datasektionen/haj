defmodule Haj.Responsibilities.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responsibility_comments" do
    field :text, :string
    field :text_html, :string

    belongs_to :show, Haj.Spex.Show
    belongs_to :user, Haj.Accounts.User
    belongs_to :responsibility, Haj.Responsibilities.Responsibility

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text, :text_html, :show_id, :user_id, :responsibility_id])
    |> validate_required([:text])
    |> gen_html_text()
  end

  defp gen_html_text(%{valid?: true, changes: %{text: text}} = changeset) do
    put_change(changeset, :text_html, Haj.Markdown.to_html!(text, with_ids: true))
  end

  defp gen_html_text(changeset), do: changeset
end
