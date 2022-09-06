defmodule HajWeb.ApplicationView do
  use HajWeb, :view

  import HajWeb.LiveComponents.Table

  defp all_groups(application) do
    Enum.map(application.application_show_groups, fn %{show_group: %{group: group}} ->
      group.name
    end)
    |> Enum.join(", ")
  end
end
