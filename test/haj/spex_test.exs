defmodule Haj.SpexTest do
  use Haj.DataCase

  alias Haj.Spex

  describe "group" do
    alias Haj.Spex.Groups

    import Haj.SpexFixtures

    @invalid_attrs %{name: nil}

    test "list_group/0 returns all group" do
      groups = groups_fixture()
      assert Spex.list_group() == [groups]
    end

    test "get_groups!/1 returns the groups with given id" do
      groups = groups_fixture()
      assert Spex.get_groups!(groups.id) == groups
    end

    test "create_groups/1 with valid data creates a groups" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Groups{} = groups} = Spex.create_groups(valid_attrs)
      assert groups.name == "some name"
    end

    test "create_groups/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spex.create_groups(@invalid_attrs)
    end

    test "update_groups/2 with valid data updates the groups" do
      groups = groups_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Groups{} = groups} = Spex.update_groups(groups, update_attrs)
      assert groups.name == "some updated name"
    end

    test "update_groups/2 with invalid data returns error changeset" do
      groups = groups_fixture()
      assert {:error, %Ecto.Changeset{}} = Spex.update_groups(groups, @invalid_attrs)
      assert groups == Spex.get_groups!(groups.id)
    end

    test "delete_groups/1 deletes the groups" do
      groups = groups_fixture()
      assert {:ok, %Groups{}} = Spex.delete_groups(groups)
      assert_raise Ecto.NoResultsError, fn -> Spex.get_groups!(groups.id) end
    end

    test "change_groups/1 returns a groups changeset" do
      groups = groups_fixture()
      assert %Ecto.Changeset{} = Spex.change_groups(groups)
    end
  end

  describe "groups" do
    alias Haj.Spex.Group

    import Haj.SpexFixtures

    @invalid_attrs %{name: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Spex.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Spex.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Group{} = group} = Spex.create_group(valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spex.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Group{} = group} = Spex.update_group(group, update_attrs)
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Spex.update_group(group, @invalid_attrs)
      assert group == Spex.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Spex.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Spex.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Spex.change_group(group)
    end
  end

  describe "show_groups" do
    alias Haj.Spex.ShowGroup

    import Haj.SpexFixtures

    @invalid_attrs %{}

    test "list_show_groups/0 returns all show_groups" do
      show_group = show_group_fixture()
      assert Spex.list_show_groups() == [show_group]
    end

    test "get_show_group!/1 returns the show_group with given id" do
      show_group = show_group_fixture()
      assert Spex.get_show_group!(show_group.id) == show_group
    end

    test "create_show_group/1 with valid data creates a show_group" do
      valid_attrs = %{}

      assert {:ok, %ShowGroup{} = show_group} = Spex.create_show_group(valid_attrs)
    end

    test "create_show_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spex.create_show_group(@invalid_attrs)
    end

    test "update_show_group/2 with valid data updates the show_group" do
      show_group = show_group_fixture()
      update_attrs = %{}

      assert {:ok, %ShowGroup{} = show_group} = Spex.update_show_group(show_group, update_attrs)
    end

    test "update_show_group/2 with invalid data returns error changeset" do
      show_group = show_group_fixture()
      assert {:error, %Ecto.Changeset{}} = Spex.update_show_group(show_group, @invalid_attrs)
      assert show_group == Spex.get_show_group!(show_group.id)
    end

    test "delete_show_group/1 deletes the show_group" do
      show_group = show_group_fixture()
      assert {:ok, %ShowGroup{}} = Spex.delete_show_group(show_group)
      assert_raise Ecto.NoResultsError, fn -> Spex.get_show_group!(show_group.id) end
    end

    test "change_show_group/1 returns a show_group changeset" do
      show_group = show_group_fixture()
      assert %Ecto.Changeset{} = Spex.change_show_group(show_group)
    end
  end

  describe "group_membership" do
    alias Haj.Spex.GroupMembership

    import Haj.SpexFixtures

    @invalid_attrs %{role: nil}

    test "list_group_membership/0 returns all group_membership" do
      group_membership = group_membership_fixture()
      assert Spex.list_group_membership() == [group_membership]
    end

    test "get_group_membership!/1 returns the group_membership with given id" do
      group_membership = group_membership_fixture()
      assert Spex.get_group_membership!(group_membership.id) == group_membership
    end

    test "create_group_membership/1 with valid data creates a group_membership" do
      valid_attrs = %{role: :chef}

      assert {:ok, %GroupMembership{} = group_membership} = Spex.create_group_membership(valid_attrs)
      assert group_membership.role == :chef
    end

    test "create_group_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spex.create_group_membership(@invalid_attrs)
    end

    test "update_group_membership/2 with valid data updates the group_membership" do
      group_membership = group_membership_fixture()
      update_attrs = %{role: :gruppis}

      assert {:ok, %GroupMembership{} = group_membership} = Spex.update_group_membership(group_membership, update_attrs)
      assert group_membership.role == :gruppis
    end

    test "update_group_membership/2 with invalid data returns error changeset" do
      group_membership = group_membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Spex.update_group_membership(group_membership, @invalid_attrs)
      assert group_membership == Spex.get_group_membership!(group_membership.id)
    end

    test "delete_group_membership/1 deletes the group_membership" do
      group_membership = group_membership_fixture()
      assert {:ok, %GroupMembership{}} = Spex.delete_group_membership(group_membership)
      assert_raise Ecto.NoResultsError, fn -> Spex.get_group_membership!(group_membership.id) end
    end

    test "change_group_membership/1 returns a group_membership changeset" do
      group_membership = group_membership_fixture()
      assert %Ecto.Changeset{} = Spex.change_group_membership(group_membership)
    end
  end

  describe "group_memberships" do
    alias Haj.Spex.GroupMembership

    import Haj.SpexFixtures

    @invalid_attrs %{role: nil}

    test "list_group_memberships/0 returns all group_memberships" do
      group_membership = group_membership_fixture()
      assert Spex.list_group_memberships() == [group_membership]
    end

    test "get_group_membership!/1 returns the group_membership with given id" do
      group_membership = group_membership_fixture()
      assert Spex.get_group_membership!(group_membership.id) == group_membership
    end

    test "create_group_membership/1 with valid data creates a group_membership" do
      valid_attrs = %{role: :chef}

      assert {:ok, %GroupMembership{} = group_membership} = Spex.create_group_membership(valid_attrs)
      assert group_membership.role == :chef
    end

    test "create_group_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spex.create_group_membership(@invalid_attrs)
    end

    test "update_group_membership/2 with valid data updates the group_membership" do
      group_membership = group_membership_fixture()
      update_attrs = %{role: :gruppis}

      assert {:ok, %GroupMembership{} = group_membership} = Spex.update_group_membership(group_membership, update_attrs)
      assert group_membership.role == :gruppis
    end

    test "update_group_membership/2 with invalid data returns error changeset" do
      group_membership = group_membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Spex.update_group_membership(group_membership, @invalid_attrs)
      assert group_membership == Spex.get_group_membership!(group_membership.id)
    end

    test "delete_group_membership/1 deletes the group_membership" do
      group_membership = group_membership_fixture()
      assert {:ok, %GroupMembership{}} = Spex.delete_group_membership(group_membership)
      assert_raise Ecto.NoResultsError, fn -> Spex.get_group_membership!(group_membership.id) end
    end

    test "change_group_membership/1 returns a group_membership changeset" do
      group_membership = group_membership_fixture()
      assert %Ecto.Changeset{} = Spex.change_group_membership(group_membership)
    end
  end
end
