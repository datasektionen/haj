defmodule Haj.EventsTest do
  use Haj.DataCase

  alias Haj.Events

  describe "events" do
    alias Haj.Events.Event

    import Haj.EventsFixtures

    @invalid_attrs %{
      description: nil,
      event_date: nil,
      image: nil,
      name: nil,
      purchase_deadline: nil,
      ticket_limit: nil
    }

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{
        description: "some description",
        event_date: ~U[2022-11-21 19:51:00Z],
        image: "some image",
        name: "some name",
        purchase_deadline: ~U[2022-11-21 19:51:00Z],
        ticket_limit: 42
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.event_date == ~U[2022-11-21 19:51:00Z]
      assert event.image == "some image"
      assert event.name == "some name"
      assert event.purchase_deadline == ~U[2022-11-21 19:51:00Z]
      assert event.ticket_limit == 42
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        description: "some updated description",
        event_date: ~U[2022-11-22 19:51:00Z],
        image: "some updated image",
        name: "some updated name",
        purchase_deadline: ~U[2022-11-22 19:51:00Z],
        ticket_limit: 43
      }

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.event_date == ~U[2022-11-22 19:51:00Z]
      assert event.image == "some updated image"
      assert event.name == "some updated name"
      assert event.purchase_deadline == ~U[2022-11-22 19:51:00Z]
      assert event.ticket_limit == 43
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end

  describe "ticket_types" do
    alias Haj.Events.TicketType

    import Haj.EventsFixtures

    @invalid_attrs %{description: nil, name: nil, price: nil}

    test "list_ticket_types/0 returns all ticket_types" do
      ticket_type = ticket_type_fixture()
      assert Events.list_ticket_types() == [ticket_type]
    end

    test "get_ticket_type!/1 returns the ticket_type with given id" do
      ticket_type = ticket_type_fixture()
      assert Events.get_ticket_type!(ticket_type.id) == ticket_type
    end

    test "create_ticket_type/1 with valid data creates a ticket_type" do
      valid_attrs = %{description: "some description", name: "some name", price: 42}

      assert {:ok, %TicketType{} = ticket_type} = Events.create_ticket_type(valid_attrs)
      assert ticket_type.description == "some description"
      assert ticket_type.name == "some name"
      assert ticket_type.price == 42
    end

    test "create_ticket_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_ticket_type(@invalid_attrs)
    end

    test "update_ticket_type/2 with valid data updates the ticket_type" do
      ticket_type = ticket_type_fixture()

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        price: 43
      }

      assert {:ok, %TicketType{} = ticket_type} =
               Events.update_ticket_type(ticket_type, update_attrs)

      assert ticket_type.description == "some updated description"
      assert ticket_type.name == "some updated name"
      assert ticket_type.price == 43
    end

    test "update_ticket_type/2 with invalid data returns error changeset" do
      ticket_type = ticket_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_ticket_type(ticket_type, @invalid_attrs)
      assert ticket_type == Events.get_ticket_type!(ticket_type.id)
    end

    test "delete_ticket_type/1 deletes the ticket_type" do
      ticket_type = ticket_type_fixture()
      assert {:ok, %TicketType{}} = Events.delete_ticket_type(ticket_type)
      assert_raise Ecto.NoResultsError, fn -> Events.get_ticket_type!(ticket_type.id) end
    end

    test "change_ticket_type/1 returns a ticket_type changeset" do
      ticket_type = ticket_type_fixture()
      assert %Ecto.Changeset{} = Events.change_ticket_type(ticket_type)
    end
  end

  describe "event_registrations" do
    alias Haj.Events.EventRegistration

    import Haj.EventsFixtures

    @invalid_attrs %{}

    test "list_event_registrations/0 returns all event_registrations" do
      event_registration = event_registration_fixture()
      assert Events.list_event_registrations() == [event_registration]
    end

    test "get_event_registration!/1 returns the event_registration with given id" do
      event_registration = event_registration_fixture()
      assert Events.get_event_registration!(event_registration.id) == event_registration
    end

    test "create_event_registration/1 with valid data creates a event_registration" do
      valid_attrs = %{}

      assert {:ok, %EventRegistration{} = event_registration} =
               Events.create_event_registration(valid_attrs)
    end

    test "create_event_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event_registration(@invalid_attrs)
    end

    test "update_event_registration/2 with valid data updates the event_registration" do
      event_registration = event_registration_fixture()
      update_attrs = %{}

      assert {:ok, %EventRegistration{} = event_registration} =
               Events.update_event_registration(event_registration, update_attrs)
    end

    test "update_event_registration/2 with invalid data returns error changeset" do
      event_registration = event_registration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Events.update_event_registration(event_registration, @invalid_attrs)

      assert event_registration == Events.get_event_registration!(event_registration.id)
    end

    test "delete_event_registration/1 deletes the event_registration" do
      event_registration = event_registration_fixture()
      assert {:ok, %EventRegistration{}} = Events.delete_event_registration(event_registration)

      assert_raise Ecto.NoResultsError, fn ->
        Events.get_event_registration!(event_registration.id)
      end
    end

    test "change_event_registration/1 returns a event_registration changeset" do
      event_registration = event_registration_fixture()
      assert %Ecto.Changeset{} = Events.change_event_registration(event_registration)
    end
  end
end
