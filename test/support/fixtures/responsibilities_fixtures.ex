defmodule Haj.ResponsibilitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Responsibilities` context.
  """

  @doc """
  Generate a responsibility.
  """
  def responsibility_fixture(attrs \\ %{}) do
    show = Haj.SpexFixtures.show_fixture()

    {:ok, responsibility} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Haj.Responsibilities.create_responsibility()
      |> Haj.Repo.preload(responsible_users:
        from ru in ResponsibleUser,
          where: r.id == ru.responsibility_id and ru.show_id == ^current_spex.id,
          left_join: u in assoc(ru, :user),
          preload: [responsible_users: u]

      )

    responsibility
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> Haj.Responsibilities.create_comment()

    comment
  end

  @doc """
  Generate a responsible_user.
  """
  def responsible_user_fixture(attrs \\ %{}) do
    {:ok, responsible_user} =
      attrs
      |> Enum.into(%{})
      |> Haj.Responsibilities.create_responsible_user()

    responsible_user
  end
end
