defmodule Haj.SpexFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Spex` context.
  """

  @doc """
  Generate a show.
  """
  def show_fixture(attrs \\ %{}) do
    {:ok, show} =
      attrs
      |> Enum.into(%{
        description: "some description",
        or_title: "some or_title",
        title: "some title",
        year: ~D[2022-06-15]
      })
      |> Haj.Spex.create_show()

    show
  end

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Haj.Spex.create_group()

    group
  end

  @doc """
  Generate a show_group.
  """
  def show_group_fixture(attrs \\ %{}) do
    show = show_fixture()
    group = group_fixture()
    {:ok, show_group} =
      attrs
      |> Enum.into(%{
        group_id: group.id,
        show_id: show.id
      })
      |> Haj.Spex.create_show_group()

    show_group
  end

  @doc """
  Generate a group_membership.
  """
  def group_membership_fixture(attrs \\ %{}) do
    {:ok, group_membership} =
      attrs
      |> Enum.into(%{
        role: :chef
      })
      |> Haj.Spex.create_group_membership()

    group_membership
  end
end
