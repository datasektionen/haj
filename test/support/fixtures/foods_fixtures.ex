defmodule Haj.FoodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Foods` context.
  """

  @doc """
  Generate a food.
  """
  def food_fixture(attrs \\ %{}) do
    {:ok, food} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Haj.Foods.create_food()

    food
  end
end
