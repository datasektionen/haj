defmodule Haj.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :description, :string
    field :event_date, :utc_datetime
    field :image, :string
    field :name, :string
    field :purchase_deadline, :utc_datetime
    field :ticket_limit, :integer

    has_many :ticket_types, Haj.Events.TicketType

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :description, :image, :ticket_limit, :event_date, :purchase_deadline])
    |> validate_required([
      :name,
      :description,
      :image,
      :ticket_limit,
      :event_date,
      :purchase_deadline
    ])
  end
end
