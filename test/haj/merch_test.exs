defmodule Haj.MerchTest do
  use Haj.DataCase

  alias Haj.Merch

  describe "merch_items" do
    alias Haj.Merch.MerchItem

    import Haj.MerchFixtures

    @invalid_attrs %{name: nil, price: nil, sizes: nil}

    test "list_merch_items/0 returns all merch_items" do
      merch_item = merch_item_fixture()
      assert Merch.list_merch_items() == [merch_item]
    end

    test "get_merch_item!/1 returns the merch_item with given id" do
      merch_item = merch_item_fixture()
      assert Merch.get_merch_item!(merch_item.id) == merch_item
    end

    test "create_merch_item/1 with valid data creates a merch_item" do
      valid_attrs = %{name: "some name", price: 42, sizes: ["XS","S","L"]}

      assert {:ok, %MerchItem{} = merch_item} = Merch.create_merch_item(valid_attrs)
      assert merch_item.name == "some name"
      assert merch_item.price == 42
      assert merch_item.sizes == ["XS", "S", "L"]
    end

    test "create_merch_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Merch.create_merch_item(@invalid_attrs)
    end

    test "update_merch_item/2 with valid data updates the merch_item" do
      merch_item = merch_item_fixture()
      update_attrs = %{name: "some updated name", price: 43, sizes: ["X"]}

      assert {:ok, %MerchItem{} = merch_item} = Merch.update_merch_item(merch_item, update_attrs)
      assert merch_item.name == "some updated name"
      assert merch_item.price == 43
      assert merch_item.sizes == ["X"]
    end

    test "update_merch_item/2 with invalid data returns error changeset" do
      merch_item = merch_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Merch.update_merch_item(merch_item, @invalid_attrs)
      assert merch_item == Merch.get_merch_item!(merch_item.id)
    end

    test "delete_merch_item/1 deletes the merch_item" do
      merch_item = merch_item_fixture()
      assert {:ok, %MerchItem{}} = Merch.delete_merch_item(merch_item)
      assert_raise Ecto.NoResultsError, fn -> Merch.get_merch_item!(merch_item.id) end
    end

    test "change_merch_item/1 returns a merch_item changeset" do
      merch_item = merch_item_fixture()
      assert %Ecto.Changeset{} = Merch.change_merch_item(merch_item)
    end
  end

  describe "merch_orders" do
    alias Haj.Merch.MerchOrder

    import Haj.MerchFixtures

    @invalid_attrs %{paid: nil}

    test "list_merch_orders/0 returns all merch_orders" do
      merch_order = merch_order_fixture()
      assert Merch.list_merch_orders() == [merch_order]
    end

    test "get_merch_order!/1 returns the merch_order with given id" do
      merch_order = merch_order_fixture()
      assert Merch.get_merch_order!(merch_order.id) == merch_order
    end

    test "create_merch_order/1 with valid data creates a merch_order" do
      valid_attrs = %{paid: true}

      assert {:ok, %MerchOrder{} = merch_order} = Merch.create_merch_order(valid_attrs)
      assert merch_order.paid == true
    end

    test "create_merch_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Merch.create_merch_order(@invalid_attrs)
    end

    test "update_merch_order/2 with valid data updates the merch_order" do
      merch_order = merch_order_fixture()
      update_attrs = %{paid: false}

      assert {:ok, %MerchOrder{} = merch_order} = Merch.update_merch_order(merch_order, update_attrs)
      assert merch_order.paid == false
    end

    test "update_merch_order/2 with invalid data returns error changeset" do
      merch_order = merch_order_fixture()
      assert {:error, %Ecto.Changeset{}} = Merch.update_merch_order(merch_order, @invalid_attrs)
      assert merch_order == Merch.get_merch_order!(merch_order.id)
    end

    test "delete_merch_order/1 deletes the merch_order" do
      merch_order = merch_order_fixture()
      assert {:ok, %MerchOrder{}} = Merch.delete_merch_order(merch_order)
      assert_raise Ecto.NoResultsError, fn -> Merch.get_merch_order!(merch_order.id) end
    end

    test "change_merch_order/1 returns a merch_order changeset" do
      merch_order = merch_order_fixture()
      assert %Ecto.Changeset{} = Merch.change_merch_order(merch_order)
    end
  end

  describe "merch_order_items" do
    alias Haj.Merch.MerchOrderItem

    import Haj.MerchFixtures

    @invalid_attrs %{count: nil, size: nil}

    test "list_merch_order_items/0 returns all merch_order_items" do
      merch_order_item = merch_order_item_fixture()
      assert Merch.list_merch_order_items() == [merch_order_item]
    end

    test "get_merch_order_item!/1 returns the merch_order_item with given id" do
      merch_order_item = merch_order_item_fixture()
      assert Merch.get_merch_order_item!(merch_order_item.id) == merch_order_item
    end

    test "create_merch_order_item/1 with valid data creates a merch_order_item" do
      valid_attrs = %{count: 42, size: "some size"}

      assert {:ok, %MerchOrderItem{} = merch_order_item} = Merch.create_merch_order_item(valid_attrs)
      assert merch_order_item.count == 42
      assert merch_order_item.size == "some size"
    end

    test "create_merch_order_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Merch.create_merch_order_item(@invalid_attrs)
    end

    test "update_merch_order_item/2 with valid data updates the merch_order_item" do
      merch_order_item = merch_order_item_fixture()
      update_attrs = %{count: 43, size: "some updated size"}

      assert {:ok, %MerchOrderItem{} = merch_order_item} = Merch.update_merch_order_item(merch_order_item, update_attrs)
      assert merch_order_item.count == 43
      assert merch_order_item.size == "some updated size"
    end

    test "update_merch_order_item/2 with invalid data returns error changeset" do
      merch_order_item = merch_order_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Merch.update_merch_order_item(merch_order_item, @invalid_attrs)
      assert merch_order_item == Merch.get_merch_order_item!(merch_order_item.id)
    end

    test "delete_merch_order_item/1 deletes the merch_order_item" do
      merch_order_item = merch_order_item_fixture()
      assert {:ok, %MerchOrderItem{}} = Merch.delete_merch_order_item(merch_order_item)
      assert_raise Ecto.NoResultsError, fn -> Merch.get_merch_order_item!(merch_order_item.id) end
    end

    test "change_merch_order_item/1 returns a merch_order_item changeset" do
      merch_order_item = merch_order_item_fixture()
      assert %Ecto.Changeset{} = Merch.change_merch_order_item(merch_order_item)
    end
  end
end
