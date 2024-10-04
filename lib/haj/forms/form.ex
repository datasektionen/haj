defmodule Haj.Forms.Form do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forms" do
    field :description, :string
    field :name, :string

    has_many :events, Haj.Events.Event
    has_many :questions, Haj.Forms.Question, on_replace: :delete
    has_many :responses, Haj.Forms.Response, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(form, attrs) do
    form
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> cast_assoc(:questions, sort_param: :questions_sort, drop_param: :questions_drop)
  end
end

defimpl Phoenix.HTML.Safe, for: Haj.Forms.Form do
  def to_iodata(form) do
    Phoenix.HTML.Engine.html_escape(form.name)
  end
end
