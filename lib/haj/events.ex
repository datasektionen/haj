defmodule Haj.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Events.Event
  alias Haj.Events.TicketType
  alias Haj.Events.EventRegistration

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    query =
      from e in Event,
        preload: [:ticket_types]

    Repo.all(query)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id, preloads \\ [:ticket_types, :form]) do
    Repo.one!(
      from e in Event,
        where: e.id == ^id,
        preload: ^preloads
    )
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}, opts \\ []) do
    with_tickets = Keyword.get(opts, :with_tickets, false)

    %Event{}
    |> Event.changeset(attrs, with_tickets: with_tickets)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs, opts \\ []) do
    with_tickets = Keyword.get(opts, :with_tickets, false)

    event
    |> Event.changeset(attrs, with_tickets: with_tickets)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}, opts \\ []) do
    with_tickets = Keyword.get(opts, :with_tickets, false)

    event
    |> Event.changeset(attrs, with_tickets: with_tickets)
  end

  @doc """
  Returns the list of ticket_types.

  ## Examples

      iex> list_ticket_types()
      [%TicketType{}, ...]

  """
  def list_ticket_types do
    Repo.all(TicketType)
  end

  @doc """
  Gets a single ticket_type.

  Raises `Ecto.NoResultsError` if the Ticket type does not exist.

  ## Examples

      iex> get_ticket_type!(123)
      %TicketType{}

      iex> get_ticket_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket_type!(id), do: Repo.get!(TicketType, id)

  @doc """
  Creates a ticket_type.

  ## Examples

      iex> create_ticket_type(%{field: value})
      {:ok, %TicketType{}}

      iex> create_ticket_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket_type(attrs \\ %{}) do
    %TicketType{}
    |> TicketType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket_type.

  ## Examples

      iex> update_ticket_type(ticket_type, %{field: new_value})
      {:ok, %TicketType{}}

      iex> update_ticket_type(ticket_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket_type(%TicketType{} = ticket_type, attrs) do
    ticket_type
    |> TicketType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ticket_type.

  ## Examples

      iex> delete_ticket_type(ticket_type)
      {:ok, %TicketType{}}

      iex> delete_ticket_type(ticket_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket_type(%TicketType{} = ticket_type) do
    Repo.delete(ticket_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket_type changes.

  ## Examples

      iex> change_ticket_type(ticket_type)
      %Ecto.Changeset{data: %TicketType{}}

  """
  def change_ticket_type(%TicketType{} = ticket_type, attrs \\ %{}) do
    TicketType.changeset(ticket_type, attrs)
  end

  @doc """
  Returns the list of event_registrations.

  ## Examples

      iex> list_event_registrations()
      [%EventRegistration{}, ...]

  """
  def list_event_registrations do
    Repo.all(EventRegistration)
  end

  @doc """
  Returns the list of event_registrations for a given event. Preloads litteraly everything.
  """

  def list_event_registrations(event_id) do
    spex = Haj.Spex.current_spex()

    members_query =
      from gm in Haj.Spex.GroupMembership,
        join: sg in assoc(gm, :show_group),
        join: g in assoc(sg, :group),
        where: sg.show_id == ^spex.id,
        order_by: sg.id,
        preload: [show_group: {sg, group: g}]

    query =
      from r in EventRegistration,
        where: r.event_id == ^event_id,
        join: u in assoc(r, :user),
        left_join: fp in assoc(u, :foods),
        left_join: fr in assoc(r, :response),
        left_join: qr in assoc(fr, :question_responses),
        preload: [
          user: {u, [group_memberships: ^members_query, foods: fp]},
          response: {fr, question_responses: qr}
        ]

    Repo.all(query)
  end

  @doc """
  Gets a single event_registration.

  Raises `Ecto.NoResultsError` if the Event registration does not exist.

  ## Examples

      iex> get_event_registration!(123)
      %EventRegistration{}

      iex> get_event_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_registration!(id), do: Repo.get!(EventRegistration, id)

  @doc """
  Creates a event_registration.

  ## Examples

      iex> create_event_registration(%{field: value})
      {:ok, %EventRegistration{}}

      iex> create_event_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_registration(attrs \\ %{}) do
    %EventRegistration{}
    |> EventRegistration.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers({:registration, :created})
  end

  @doc """
  Updates a event_registration.

  ## Examples

      iex> update_event_registration(event_registration, %{field: new_value})
      {:ok, %EventRegistration{}}

      iex> update_event_registration(event_registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_registration(%EventRegistration{} = event_registration, attrs) do
    event_registration
    |> EventRegistration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_registration.

  ## Examples

      iex> delete_event_registration(event_registration)
      {:ok, %EventRegistration{}}

      iex> delete_event_registration(event_registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_registration(%EventRegistration{} = event_registration) do
    Repo.delete(event_registration)
    |> notify_subscribers({:registration, :deleted})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_registration changes.

  ## Examples

      iex> change_event_registration(event_registration)
      %Ecto.Changeset{data: %EventRegistration{}}

  """
  def change_event_registration(%EventRegistration{} = event_registration, attrs \\ %{}) do
    EventRegistration.changeset(event_registration, attrs)
  end

  @doc """
  Retuns the number of tickets sold for an event.
  """
  def tickets_sold(event_id) do
    # Count number of registrations for a given event
    q =
      from e in Event,
        join: t in assoc(e, :ticket_types),
        join: r in assoc(t, :registrations),
        where: e.id == ^event_id,
        select: count(r.id)

    Repo.one(q)
  end

  @doc """
  Returns a registration for an event for a user, if one exists.
  """
  def get_registration_for_user(event_id, user_id) do
    query =
      from r in EventRegistration,
        where: r.event_id == ^event_id and r.user_id == ^user_id

    Repo.one(query)
  end

  def subscribe(event_id) do
    Phoenix.PubSub.subscribe(Haj.PubSub, "event:#{event_id}")
  end

  defp notify_subscribers({:ok, result}, action) do
    topic = "event:#{result.id}"

    Phoenix.PubSub.broadcast(Haj.PubSub, topic, {__MODULE__, action, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _) do
    {:error, reason}
  end
end
