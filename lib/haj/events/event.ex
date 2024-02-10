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
    field :has_tickets, :boolean, default: true

    has_many :ticket_types, Haj.Events.TicketType, on_replace: :delete
    has_many :event_registrations, Haj.Events.EventRegistration, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(event, attrs, opts \\ []) do
    with_tickets = Keyword.get(opts, :with_tickets, false)

    if with_tickets do
      changeset_ticket_types(event, attrs)
    else
      default_changeset(event, attrs)
    end
  end

  defp default_changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :description,
      :image,
      :ticket_limit,
      :event_date,
      :purchase_deadline,
      :has_tickets
    ])
    |> validate_required([
      :name,
      :description,
      :ticket_limit,
      :event_date
    ])
    |> validate_number(:ticket_limit, greater_than: 0)
  end

  @doc false
  defp changeset_ticket_types(event, attrs) do
    event
    |> default_changeset(attrs)
    |> cast_assoc(:ticket_types,
      sort_param: :tickets_sort,
      drop_param: :tickets_drop
    )
  end
end
