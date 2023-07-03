defmodule Haj.Spex.Show do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shows" do
    field :title, :string
    field :or_title, :string
    field :description, :string
    field :year, :date
    field :application_opens, :utc_datetime
    field :application_closes, :utc_datetime
    field :slack_webhook_url, :string

    has_many :show_groups, Haj.Spex.ShowGroup
    has_many :songs, Haj.Archive.Song

    timestamps()
  end

  @doc false
  def changeset(show, attrs) do
    show
    |> cast(attrs, [
      :title,
      :or_title,
      :year,
      :description,
      :application_opens,
      :application_closes,
      :slack_webhook_url
    ])
    |> validate_dates_ok()
    |> validate_required([:title, :or_title, :year, :description])
  end

  defp validate_dates_ok(changeset) do
    show_date = get_field(changeset, :year)
    app_open = get_field(changeset, :application_opens)
    app_closes = get_field(changeset, :application_closes)

    cond do
      app_closes == nil ->
        changeset

      Date.compare(app_closes, show_date) == :gt ->
        add_error(changeset, :application_closes, "cannot be later than show date")

      Date.compare(app_open, app_closes) == :gt ->
        add_error(changeset, :application_opens, "cannot be later than application open date")

      true ->
        changeset
    end
  end
end
