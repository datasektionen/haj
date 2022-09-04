defmodule HajWeb.MembersView do
  use HajWeb, :view

  def table(assigns), do: HajWeb.LiveComponents.Table.table(assigns)

end
