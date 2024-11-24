defmodule Haj.Merch do
  @moduledoc """
  The Merch context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Merch.MerchItem

  @doc """
  Returns the list of merch_items.

  ## Examples

      iex> list_merch_items()
      [%MerchItem{}, ...]

  """
  def list_merch_items do
    Repo.all(MerchItem)
  end

  @doc """
  Returns the list of merch_items for a show

  ## Examples

      iex> list_merch_items(123)
      [%MerchItem{}, ...]

  """
  def list_merch_items_for_show(show_id) do
    Repo.all(from mi in MerchItem, where: mi.show_id == ^show_id)
  end

  @doc """
  Gets a single merch_item.

  Raises `Ecto.NoResultsError` if the Merch item does not exist.

  ## Examples

      iex> get_merch_item!(123)
      %MerchItem{}

      iex> get_merch_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_merch_item!(id), do: Repo.get!(MerchItem, id)

  @doc """
  Creates a merch_item.

  ## Examples

      iex> create_merch_item(%{field: value})
      {:ok, %MerchItem{}}

      iex> create_merch_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_merch_item(attrs \\ %{}, after_save \\ &{:ok, &1}) do
    %MerchItem{}
    |> MerchItem.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  @doc """
  Updates a merch_item.

  ## Examples

      iex> update_merch_item(merch_item, %{field: new_value})
      {:ok, %MerchItem{}}

      iex> update_merch_item(merch_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_merch_item(%MerchItem{} = merch_item, attrs, after_save \\ &{:ok, &1}) do
    merch_item
    |> MerchItem.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  @doc """
  Deletes a merch_item.

  ## Examples

      iex> delete_merch_item(merch_item)
      {:ok, %MerchItem{}}

      iex> delete_merch_item(merch_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_merch_item(%MerchItem{} = merch_item) do
    merch_item
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.no_assoc_constraint(:merch_order_items)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merch_item changes.

  ## Examples

      iex> change_merch_item(merch_item)
      %Ecto.Changeset{data: %MerchItem{}}

  """
  def change_merch_item(%MerchItem{} = merch_item, attrs \\ %{}) do
    MerchItem.changeset(merch_item, attrs)
  end

  alias Haj.Merch.MerchOrder

  @doc """
  Returns the list of merch_orders.

  ## Examples

      iex> list_merch_orders()
      [%MerchOrder{}, ...]

  """
  def list_merch_orders do
    Repo.all(MerchOrder)
  end

  @doc """
  Returns the list of merch orders for a show, only returns orders that have
  associated order items, ie. does not include empty orders.
  """
  def list_merch_orders_for_show(show_id) do
    Repo.all(
      from mo in MerchOrder,
        distinct: mo.id,
        right_join: moi in assoc(mo, :merch_order_items),
        where: mo.show_id == ^show_id
    )
  end

  @doc """
  Gets a single merch_order.

  Raises `Ecto.NoResultsError` if the Merch order does not exist.

  ## Examples

      iex> get_merch_order!(123)
      %MerchOrder{}

      iex> get_merch_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_merch_order!(id), do: Repo.get!(MerchOrder, id)

  @doc """
  Creates a merch_order.

  ## Examples

      iex> create_merch_order(%{field: value})
      {:ok, %MerchOrder{}}

      iex> create_merch_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_merch_order(attrs \\ %{}) do
    %MerchOrder{}
    |> MerchOrder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a merch_order.

  ## Examples

      iex> update_merch_order(merch_order, %{field: new_value})
      {:ok, %MerchOrder{}}

      iex> update_merch_order(merch_order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_merch_order(%MerchOrder{} = merch_order, attrs) do
    merch_order
    |> MerchOrder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a merch_order.

  ## Examples

      iex> delete_merch_order(merch_order)
      {:ok, %MerchOrder{}}

      iex> delete_merch_order(merch_order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_merch_order(%MerchOrder{} = merch_order) do
    Repo.delete(merch_order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merch_order changes.

  ## Examples

      iex> change_merch_order(merch_order)
      %Ecto.Changeset{data: %MerchOrder{}}

  """
  def change_merch_order(%MerchOrder{} = merch_order, attrs \\ %{}) do
    MerchOrder.changeset(merch_order, attrs)
  end

  alias Haj.Merch.MerchOrderItem

  @doc """
  Returns the list of merch_order_items.

  ## Examples

      iex> list_merch_order_items()
      [%MerchOrderItem{}, ...]

  """
  def list_merch_order_items do
    Repo.all(MerchOrderItem)
  end

  @doc """
  Gets a single merch_order_item.

  Raises `Ecto.NoResultsError` if the Merch order item does not exist.

  ## Examples

      iex> get_merch_order_item!(123)
      %MerchOrderItem{}

      iex> get_merch_order_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_merch_order_item!(id), do: Repo.get!(MerchOrderItem, id)

  @doc """
  Creates a merch_order_item.

  ## Examples

      iex> create_merch_order_item(%{field: value})
      {:ok, %MerchOrderItem{}}

      iex> create_merch_order_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_merch_order_item(attrs \\ %{}) do
    %MerchOrderItem{}
    |> MerchOrderItem.changeset(attrs)
    |> Repo.insert()
  end

  def add_merch_order_item_to_order(show_id, user_id, merch_item_id, attrs \\ %{}) do
    Repo.transaction(fn ->
      merch_item = Repo.get(MerchItem, merch_item_id)

      if merch_item.purchase_deadline &&
           DateTime.compare(merch_item.purchase_deadline, DateTime.utc_now()) == :lt do
        Repo.rollback("Beställningsdeadline passerad.")
      end

      order_query =
        from mo in MerchOrder,
          where: mo.user_id == ^user_id and mo.show_id == ^show_id

      order =
        case Repo.one(order_query) do
          nil ->
            %MerchOrder{show_id: show_id, user_id: user_id}
            |> Repo.insert!(on_conflict: :nothing)

          result ->
            result
        end
        |> Repo.preload(merch_order_items: [merch_item: []])

      case {merch_item_id, attrs["size"]} in Enum.map(
             order.merch_order_items,
             &{&1.merch_item_id, &1.size}
           ) do
        true ->
          Repo.rollback("Denna merch är redan beställd i den här storleken.")

        false ->
          %MerchOrderItem{merch_item_id: merch_item_id, merch_order_id: order.id}
          |> MerchOrderItem.changeset(attrs)
          |> Repo.insert()
      end
    end)
  end

  def change_order_item_in_order(merch_order_item, show_id, user_id, attrs \\ %{}) do
    Repo.transaction(fn ->
      merch_item =
        Repo.one!(from mi in MerchItem, where: mi.id == ^merch_order_item.merch_item_id)

      if merch_item.purchase_deadline &&
           DateTime.compare(merch_item.purchase_deadline, DateTime.utc_now()) == :lt do
        Repo.rollback("Beställningsdeadline passerad.")
      end

      order_query =
        from mo in MerchOrder,
          where: mo.user_id == ^user_id and mo.show_id == ^show_id,
          preload: [merch_order_items: [merch_item: []]]

      order = Repo.one(order_query)

      changeset = MerchOrderItem.changeset(merch_order_item, attrs)
      size = Ecto.Changeset.get_field(changeset, :size)
      merch_item_id = Ecto.Changeset.get_field(changeset, :merch_item_id)

      previously_ordered =
        Enum.filter(order.merch_order_items, fn item ->
          item.merch_item_id == merch_item_id and item.size == size
        end)

      cond do
        previously_ordered == [] ->
          Repo.update(changeset)

        merch_order_item.id in Enum.map(previously_ordered, & &1.id) ->
          Repo.update(changeset)

        true ->
          Repo.rollback("Denna merch är redan beställd i den här storleken.")
      end
    end)
  end

  @doc """
  Updates a merch_order_item.

  ## Examples

      iex> update_merch_order_item(merch_order_item, %{field: new_value})
      {:ok, %MerchOrderItem{}}

      iex> update_merch_order_item(merch_order_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_merch_order_item(%MerchOrderItem{} = merch_order_item, attrs) do
    merch_order_item
    |> MerchOrderItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a merch_order_item.

  ## Examples

      iex> delete_merch_order_item(merch_order_item)
      {:ok, %MerchOrderItem{}}

      iex> delete_merch_order_item(merch_order_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_merch_order_item(%MerchOrderItem{} = merch_order_item) do
    Repo.transaction(fn ->
      merch_item =
        Repo.one!(from mi in MerchItem, where: mi.id == ^merch_order_item.merch_item_id)

      if merch_item.purchase_deadline &&
           DateTime.compare(merch_item.purchase_deadline, DateTime.utc_now()) == :lt do
        Repo.rollback("Beställningsdeadline passerad.")
      end

      Repo.delete!(merch_order_item)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking merch_order_item changes.

  ## Examples

      iex> change_merch_order_item(merch_order_item)
      %Ecto.Changeset{data: %MerchOrderItem{}}

  """
  def change_merch_order_item(%MerchOrderItem{} = merch_order_item, attrs \\ %{}) do
    MerchOrderItem.changeset(merch_order_item, attrs)
  end

  @doc """
  Returns all merch orders for a user.
  """
  def get_merch_orders_for_user(user_id) do
    query =
      from mo in MerchOrder,
        where: mo.user_id == ^user_id,
        preload: [merch_order_items: [merch_item: []]]

    Repo.all(query)
  end

  @doc """
  Gets a summary of merch orders for a show

  ## Examples

    iex> get_merch_order_summary(4)
    {:ok, [%{item: %MerchItem{}, count: 2, size: 'XL'}, ...]}
  """
  def get_merch_order_summary(show_id) do
    query =
      from mi in MerchItem,
        join: moi in assoc(mi, :merch_order_items),
        where: mi.show_id == ^show_id,
        group_by: [mi.id, moi.size],
        order_by: [mi.id, moi.size],
        select: %{item: mi, count: sum(moi.count), size: moi.size}

    Repo.all(query)
  end

  @doc """
  Gets the previous order for for current show for a particular user, if there
  are none, creates a new order.

  ## Examples

    iex> get_previous_order(4, 2)
    {:ok, %Order{}}


    iex> get_previous_order(3, 1)
    {:error, changeset}
  """
  def create_or_get_previous_order(user_id) do
    current_show = Haj.Spex.current_spex()

    query =
      from mo in MerchOrder,
        where: mo.user_id == ^user_id and mo.show_id == ^current_show.id,
        preload: [merch_order_items: [merch_item: []]]

    case Repo.one(query) do
      %MerchOrder{} = order ->
        {:ok, order}

      nil ->
        {:ok, order} = create_merch_order(%{"user_id" => user_id, "show_id" => current_show.id})
        {:ok, order |> Repo.preload(merch_order_items: [merch_item: []])}
    end
  end

  @doc """
  Gets the Merch Order Items for the user for the current show
  """
  def get_current_merch_order_items(user_id) do
    show = Haj.Spex.current_spex()

    query =
      from moi in MerchOrderItem,
        join: mo in assoc(moi, :merch_order),
        where: mo.user_id == ^user_id and mo.show_id == ^show.id,
        preload: [:merch_order, :merch_item]

    Repo.all(query)
  end

  defp after_save({:ok, result}, func) do
    {:ok, _result} = func.(result)
  end

  defp after_save(error, _func), do: error
end
