defmodule Haj.Events.TicketType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ticket_types" do
    field :description, :string
    field :name, :string
    field :price, :integer

    belongs_to :event, Haj.Events.Event
    has_many :registrations, Haj.Events.EventRegistration

    timestamps()
  end

  @doc false
  def changeset(ticket_type, attrs) do
    ticket_type
    |> cast(attrs, [:price, :name, :description])
    |> validate_required([:price, :name, :description])
  end
end
