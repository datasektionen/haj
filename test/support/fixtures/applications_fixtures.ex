defmodule Haj.ApplicationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Applications` context.
  """

  @doc """
  Generate a application.
  """
  def application_fixture(attrs \\ %{}) do
    {:ok, application} =
      attrs
      |> Enum.into(%{

      })
      |> Haj.Applications.create_application()

    application
  end
end
