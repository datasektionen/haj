defmodule HajWeb.MembersView do
  use HajWeb, :view

  def table(assigns), do: HajWeb.Components.Table.table(assigns)
end
