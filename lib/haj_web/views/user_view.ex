defmodule HajWeb.UserHTML do
  use HajWeb, :view

  embed_templates("../templates/user/*")

  def name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def display_foods(user) do
    prefs = Enum.map(user.foods, fn %{name: name} -> name end) |> Enum.join(", ")

    case user.food_preference_other do
      nil -> prefs
      other -> prefs <> ". " <> other
    end
  end
end
