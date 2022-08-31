defmodule Haj.ApplicationsTest do
  use Haj.DataCase

  alias Haj.Applications

  describe "applications" do
    alias Haj.Applications.Application

    import Haj.ApplicationsFixtures

    @invalid_attrs %{}

    test "list_applications/0 returns all applications" do
      application = application_fixture()
      assert Applications.list_applications() == [application]
    end

    test "get_application!/1 returns the application with given id" do
      application = application_fixture()
      assert Applications.get_application!(application.id) == application
    end

    test "create_application/1 with valid data creates a application" do
      valid_attrs = %{}

      assert {:ok, %Application{} = application} = Applications.create_application(valid_attrs)
    end

    test "create_application/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Applications.create_application(@invalid_attrs)
    end

    test "update_application/2 with valid data updates the application" do
      application = application_fixture()
      update_attrs = %{}

      assert {:ok, %Application{} = application} = Applications.update_application(application, update_attrs)
    end

    test "update_application/2 with invalid data returns error changeset" do
      application = application_fixture()
      assert {:error, %Ecto.Changeset{}} = Applications.update_application(application, @invalid_attrs)
      assert application == Applications.get_application!(application.id)
    end

    test "delete_application/1 deletes the application" do
      application = application_fixture()
      assert {:ok, %Application{}} = Applications.delete_application(application)
      assert_raise Ecto.NoResultsError, fn -> Applications.get_application!(application.id) end
    end

    test "change_application/1 returns a application changeset" do
      application = application_fixture()
      assert %Ecto.Changeset{} = Applications.change_application(application)
    end
  end
end
