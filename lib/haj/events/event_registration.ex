defmodule Haj.Events.EventRegistration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_registrations" do
    belongs_to :ticket_type, Haj.Events.TicketType
    belongs_to :user, Haj.Accounts.User
    belongs_to :event, Haj.Events.Event

    timestamps()
  end

  @doc false
  def changeset(event_registration, attrs) do
    event_registration
    |> cast(attrs, [:ticket_type_id, :user_id, :event_id])
    |> validate_required([:ticket_type_id, :user_id])
  end
end