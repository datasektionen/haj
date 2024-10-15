defmodule Haj.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        last_name: "some last_name",
        username: "some username"
      })
      |> Haj.Accounts.create_user()

    user |> Map.put(:full_name, "#{user.first_name} #{user.last_name}")
  end
end
