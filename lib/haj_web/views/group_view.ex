defmodule HajWeb.GroupView do
  use HajWeb, :view

  def table(assigns), do: HajWeb.LiveComponents.Table.table(assigns)

  defp is_admin?(show_group, user) do
    user.role == :admin ||
      show_group.group_memberships
      |> Enum.any?(fn %{user_id: id, role: role} ->
        role == :chef && id == user.id
      end)
  end

  defp all_groups(application) do
    Enum.map(application.application_show_groups, fn %{show_group: %{group: group}} ->
      group.name
    end)
    |> Enum.join(", ")
  end

  def number_of_members(show_group) do
    Enum.count(show_group.group_memberships)
  end

  def chefer(show_group) do
    Enum.filter(show_group.group_memberships, fn %{role: role} -> role == :chef end)
    |> Enum.map(fn %{user: user} ->
      user
    end)
  end

  def gruppisar(show_group) do
    Enum.filter(show_group.group_memberships, fn %{role: role} -> role == :gruppis end)
    |> Enum.map(fn %{user: user} ->
      user
    end)
  end

  def member_of_show_group?(user_id, %{group_memberships: members}) do
    Enum.any?(members, fn %{user_id: id} -> id == user_id end)
  end
end
