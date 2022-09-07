defmodule Haj.Spex do
  @moduledoc """
  The Spex context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Spex.Show

  @doc """
  Returns the list of shows.

  ## Examples

      iex> list_shows()
      [%Show{}, ...]

  """
  def list_shows do
    Repo.all(from s in Show, order_by: [desc: s.year])
  end

  @doc """
  Gets a single show.

  Raises `Ecto.NoResultsError` if the Show does not exist.

  ## Examples

      iex> get_show!(123)
      %Show{}

      iex> get_show!(456)
      ** (Ecto.NoResultsError)

  """
  def get_show!(id), do: Repo.get!(Show, id)

  @doc """
  Creates a show.

  ## Examples

      iex> create_show(%{field: value})
      {:ok, %Show{}}

      iex> create_show(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_show(attrs \\ %{}) do
    %Show{}
    |> Show.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a show.

  ## Examples

      iex> update_show(show, %{field: new_value})
      {:ok, %Show{}}

      iex> update_show(show, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_show(%Show{} = show, attrs) do
    show
    |> Show.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a show.

  ## Examples

      iex> delete_show(show)
      {:ok, %Show{}}

      iex> delete_show(show)
      {:error, %Ecto.Changeset{}}

  """
  def delete_show(%Show{} = show) do
    Repo.delete(show)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking show changes.

  ## Examples

      iex> change_show(show)
      %Ecto.Changeset{data: %Show{}}

  """
  def change_show(%Show{} = show, attrs \\ %{}) do
    Show.changeset(show, attrs)
  end

  alias Haj.Spex.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  alias Haj.Spex.GroupMembership

  @doc """
  Returns the list of group_memberships.

  ## Examples

      iex> list_group_memberships()
      [%GroupMembership{}, ...]

  """
  def list_group_memberships do
    Repo.all(GroupMembership)
  end

  @doc """
  Gets a single group_membership.

  Raises `Ecto.NoResultsError` if the Group membership does not exist.

  ## Examples

      iex> get_group_membership!(123)
      %GroupMembership{}

      iex> get_group_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_membership!(id), do: Repo.get!(GroupMembership, id)

  @doc """
  Creates a group_membership.

  ## Examples

      iex> create_group_membership(%{field: value})
      {:ok, %GroupMembership{}}

      iex> create_group_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_membership(attrs \\ %{}) do
    %GroupMembership{}
    |> GroupMembership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group_membership.

  ## Examples

      iex> update_group_membership(group_membership, %{field: new_value})
      {:ok, %GroupMembership{}}

      iex> update_group_membership(group_membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_membership(%GroupMembership{} = group_membership, attrs) do
    group_membership
    |> GroupMembership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group_membership.

  ## Examples

      iex> delete_group_membership(group_membership)
      {:ok, %GroupMembership{}}

      iex> delete_group_membership(group_membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_membership(%GroupMembership{} = group_membership) do
    Repo.delete(group_membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_membership changes.

  ## Examples

      iex> change_group_membership(group_membership)
      %Ecto.Changeset{data: %GroupMembership{}}

  """
  def change_group_membership(%GroupMembership{} = group_membership, attrs \\ %{}) do
    GroupMembership.changeset(group_membership, attrs)
  end

  alias Haj.Spex.ShowGroup

  @doc """
  Returns the list of show_groups.

  ## Examples

      iex> list_show_groups()
      [%ShowGroup{}, ...]

  """
  def list_show_groups do
    Repo.all(ShowGroup)
  end

  @doc """
  Gets a single show_group.

  Raises `Ecto.NoResultsError` if the Show group does not exist.

  ## Examples

      iex> get_show_group!(123)
      %ShowGroup{}

      iex> get_show_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_show_group!(id),
    do: Repo.get!(ShowGroup, id) |> Repo.preload([:group, :show, [group_memberships: [user: []]]])

  @doc """
  Creates a show_group.

  ## Examples

      iex> create_show_group(%{field: value})
      {:ok, %ShowGroup{}}

      iex> create_show_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_show_group(attrs \\ %{}) do
    %ShowGroup{}
    |> ShowGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a show_group.

  ## Examples

      iex> update_show_group(show_group, %{field: new_value})
      {:ok, %ShowGroup{}}

      iex> update_show_group(show_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_show_group(%ShowGroup{} = show_group, attrs) do
    show_group
    |> ShowGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a show_group.

  ## Examples

      iex> delete_show_group(show_group)
      {:ok, %ShowGroup{}}

      iex> delete_show_group(show_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_show_group(%ShowGroup{} = show_group) do
    Repo.delete(show_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking show_group changes.

  ## Examples

      iex> change_show_group(show_group)
      %Ecto.Changeset{data: %ShowGroup{}}

  """
  def change_show_group(%ShowGroup{} = show_group, attrs \\ %{}) do
    ShowGroup.changeset(show_group, attrs)
  end

  def current_spex() do
    Repo.one(from s in Show, order_by: [desc: s.year], limit: 1)
  end

  def list_members_for_show(show_id) do
    query = from sg in ShowGroup,
      join: gm in assoc(sg, :group_memberships),
      join: u in assoc(gm, :user),
      distinct: u.id,
      where: sg.show_id == ^show_id,
      select: u

    Repo.all(query)
  end

  def get_show_groups_for_user(userid) do
    query =
      from sg in ShowGroup,
        join: gm in assoc(sg, :group_memberships),
        where: gm.user_id == ^userid,
        preload: [show: [], group: []]

    Repo.all(query)
  end

  def get_group_by_name!(name) do
    Repo.one!(from g in Group, where: g.name == ^name)
  end

  def get_group_members(group_id) do
    %{id: spex_id} = current_spex()

    query =
      from g in Group,
        join: sg in assoc(g, :show_groups),
        join: gm in assoc(sg, :group_memberships),
        join: u in assoc(gm, :user),
        where: sg.show_id == ^spex_id and g.id == ^group_id,
        select: u

    Repo.all(query)
  end

  def get_show_groups_for_show(show_id) do
    query =
      from sg in ShowGroup,
        where: sg.show_id == ^show_id,
        left_join: gm in GroupMembership, on: gm.show_group_id == sg.id,
        left_join: u in assoc(gm, :user),
        preload: [group: [], group_memberships: {gm, user: u}]

    Repo.all(query)
  end
end
