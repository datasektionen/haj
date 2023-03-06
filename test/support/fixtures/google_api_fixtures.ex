defmodule Haj.GoogleApiFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.GoogleApi` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        access_token: "some access_token",
        expire_time: ~U[2023-03-04 20:00:00Z],
        refresh_token: "some refresh_token"
      })
      |> Haj.GoogleApi.create_token()

    token
  end
end
