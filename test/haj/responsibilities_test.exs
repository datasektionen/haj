defmodule Haj.ResponsibilitiesTest do
  use Haj.DataCase

  alias Haj.Responsibilities

  describe "responsibilities" do
    alias Haj.Responsibilities.Responsibility

    import Haj.ResponsibilitiesFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_responsibilities/0 returns all responsibilities" do
      responsibility = responsibility_fixture()
      assert Responsibilities.list_responsibilities() == [responsibility]
    end

    test "get_responsibility!/1 returns the responsibility with given id" do
      responsibility = responsibility_fixture()
      assert Responsibilities.get_responsibility!(responsibility.id) == responsibility
    end

    test "create_responsibility/1 with valid data creates a responsibility" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Responsibility{} = responsibility} =
               Responsibilities.create_responsibility(valid_attrs)

      assert responsibility.description == "some description"
      assert responsibility.name == "some name"
    end

    test "create_responsibility/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Responsibilities.create_responsibility(@invalid_attrs)
    end

    test "update_responsibility/2 with valid data updates the responsibility" do
      responsibility = responsibility_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Responsibility{} = responsibility} =
               Responsibilities.update_responsibility(responsibility, update_attrs)

      assert responsibility.description == "some updated description"
      assert responsibility.name == "some updated name"
    end

    test "update_responsibility/2 with invalid data returns error changeset" do
      responsibility = responsibility_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Responsibilities.update_responsibility(responsibility, @invalid_attrs)

      assert responsibility == Responsibilities.get_responsibility!(responsibility.id)
    end

    test "delete_responsibility/1 deletes the responsibility" do
      responsibility = responsibility_fixture()
      assert {:ok, %Responsibility{}} = Responsibilities.delete_responsibility(responsibility)

      assert_raise Ecto.NoResultsError, fn ->
        Responsibilities.get_responsibility!(responsibility.id)
      end
    end

    test "change_responsibility/1 returns a responsibility changeset" do
      responsibility = responsibility_fixture()
      assert %Ecto.Changeset{} = Responsibilities.change_responsibility(responsibility)
    end
  end

  describe "responsibility_comments" do
    alias Haj.Responsibilities.Comment

    import Haj.ResponsibilitiesFixtures

    @invalid_attrs %{text: nil}

    test "list_responsibility_comments/0 returns all responsibility_comments" do
      comment = comment_fixture()
      assert Responsibilities.list_responsibility_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Responsibilities.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{text: "some text"}

      assert {:ok, %Comment{} = comment} = Responsibilities.create_comment(valid_attrs)
      assert comment.text == "some text"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Responsibilities.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{text: "some updated text"}

      assert {:ok, %Comment{} = comment} = Responsibilities.update_comment(comment, update_attrs)
      assert comment.text == "some updated text"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Responsibilities.update_comment(comment, @invalid_attrs)

      assert comment == Responsibilities.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Responsibilities.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Responsibilities.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Responsibilities.change_comment(comment)
    end
  end

  describe "responsibility_users" do
    alias Haj.Responsibilities.ResponsibleUser

    import Haj.ResponsibilitiesFixtures

    @invalid_attrs %{}

    test "list_responsibility_users/0 returns all responsibility_users" do
      responsible_user = responsible_user_fixture()
      assert Responsibilities.list_responsibility_users() == [responsible_user]
    end

    test "get_responsible_user!/1 returns the responsible_user with given id" do
      responsible_user = responsible_user_fixture()
      assert Responsibilities.get_responsible_user!(responsible_user.id) == responsible_user
    end

    test "create_responsible_user/1 with valid data creates a responsible_user" do
      valid_attrs = %{}

      assert {:ok, %ResponsibleUser{} = responsible_user} =
               Responsibilities.create_responsible_user(valid_attrs)
    end

    test "create_responsible_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Responsibilities.create_responsible_user(@invalid_attrs)
    end

    test "update_responsible_user/2 with valid data updates the responsible_user" do
      responsible_user = responsible_user_fixture()
      update_attrs = %{}

      assert {:ok, %ResponsibleUser{} = responsible_user} =
               Responsibilities.update_responsible_user(responsible_user, update_attrs)
    end

    test "update_responsible_user/2 with invalid data returns error changeset" do
      responsible_user = responsible_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Responsibilities.update_responsible_user(responsible_user, @invalid_attrs)

      assert responsible_user == Responsibilities.get_responsible_user!(responsible_user.id)
    end

    test "delete_responsible_user/1 deletes the responsible_user" do
      responsible_user = responsible_user_fixture()

      assert {:ok, %ResponsibleUser{}} =
               Responsibilities.delete_responsible_user(responsible_user)

      assert_raise Ecto.NoResultsError, fn ->
        Responsibilities.get_responsible_user!(responsible_user.id)
      end
    end

    test "change_responsible_user/1 returns a responsible_user changeset" do
      responsible_user = responsible_user_fixture()
      assert %Ecto.Changeset{} = Responsibilities.change_responsible_user(responsible_user)
    end
  end
end
