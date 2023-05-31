# Preloading usually required an extra query.
# To do it in one query, a `join` is needed, and the call to `preload` needs to know the name of join
# This macro does both the `join` and `preload` together
defmodule Haj.Utils.Preloader do
  import Ecto, only: [assoc: 2]
  alias Ecto.Query.Builder.{Join, Preload}

  defmacro preload_join(query, association) do
    expr = quote do: assoc(l, unquote(association))
    binding = quote do: [l]
    preload_bindings = quote do: [{unquote(association), x}]
    preload_expr = quote do: [{unquote(association), x}]

    query
    |> Join.build(:left, binding, expr, nil, nil, association, nil, nil, __CALLER__)
    |> elem(0)
    |> Preload.build(preload_bindings, preload_expr, __CALLER__)
  end
end
