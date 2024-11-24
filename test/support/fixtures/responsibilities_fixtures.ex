defmodule Haj.ResponsibilitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Responsibilities` context.
  """

  @doc """
  Generate a responsibility.
  """
  def responsibility_fixture(attrs \\ %{}) do
    {:ok, responsibility} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Haj.Responsibilities.create_responsibility()

    responsibility
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        text: "some text\n## Title\n\n"
      })
      |> Haj.Responsibilities.create_comment()

    comment
  end

  @doc """
  Generate a responsible_user.
  """
  def responsible_user_fixture(attrs \\ %{}) do
    user = Haj.AccountsFixtures.user_fixture()
    show = Haj.SpexFixtures.show_fixture()
    responsibility = Haj.ResponsibilitiesFixtures.responsibility_fixture()

    {:ok, responsible_user} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        show_id: show.id,
        responsibility_id: responsibility.id
      })
      |> Haj.Responsibilities.create_responsible_user()

    responsible_user
  end
end
