defmodule Haj.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        event_date: ~U[2022-11-21 19:51:00Z],
        image: "some image",
        name: "some name",
        purchase_deadline: ~U[2022-11-21 19:51:00Z],
        ticket_limit: 42
      })
      |> Haj.Events.create_event()

    event
  end

  @doc """
  Generate a ticket_type.
  """
  def ticket_type_fixture(attrs \\ %{}) do
    {:ok, ticket_type} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: 42
      })
      |> Haj.Events.create_ticket_type()

    ticket_type
  end

  @doc """
  Generate a event_registration.
  """
  def event_registration_fixture(attrs \\ %{}) do
    {:ok, event_registration} =
      attrs
      |> Enum.into(%{

      })
      |> Haj.Events.create_event_registration()

    event_registration
  end
end
