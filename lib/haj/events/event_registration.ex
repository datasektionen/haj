defmodule Haj.Events.EventRegistration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_registrations" do
    belongs_to :ticket_type, Haj.Events.TicketType
    belongs_to :user, Haj.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(event_registration, attrs) do
    event_registration
    |> cast(attrs, [])
    |> validate_required([])
  end
end
