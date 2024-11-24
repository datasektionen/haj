defmodule Haj.MerchFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Merch` context.
  """

  @doc """
  Generate a merch_item.
  """
  def merch_item_fixture(attrs \\ %{}) do
    {:ok, merch_item} =
      attrs
      |> Enum.into(%{
        name: "some name",
        price: 42,
        sizes: ["XS", "S"]
      })
      |> Haj.Merch.create_merch_item()

    merch_item
  end

  @doc """
  Generate a merch_order.
  """
  def merch_order_fixture(attrs \\ %{}) do
    {:ok, merch_order} =
      attrs
      |> Enum.into(%{
        paid: true
      })
      |> Haj.Merch.create_merch_order()

    merch_order
  end

  @doc """
  Generate a merch_order_item.
  """
  def merch_order_item_fixture(attrs \\ %{}) do
    item = Haj.MerchFixtures.merch_item_fixture()
    order = Haj.MerchFixtures.merch_order_fixture()

    {:ok, merch_order_item} =
      attrs
      |> Enum.into(%{
        count: 42,
        size: "some size",
        merch_item_id: item.id,
        merch_order_id: order.id
      })
      |> Haj.Merch.create_merch_order_item()

    merch_order_item
  end
end
