defmodule HajWeb.Components do
  use Phoenix.Component
  use HajWeb, :verified_routes

  embed_templates "components/*"

  attr :class, :string, default: ""

  slot :step, required: true do
    attr :status, :atom, required: true
    attr :to, :string
  end

  def steps(assigns)

  attr :step, :integer, required: true
  attr :rest, :global

  def application_steps(%{step: step} = assigns) do
    number_of_statuses = 4

    statuses =
      Enum.map(1..number_of_statuses, fn index ->
        cond do
          step == index -> :current
          step > index -> :complete
          step < index -> :future
        end
      end)

    assigns =
      assign(assigns, statuses: statuses)

    ~H"""
    <.steps {@rest}>
      <:step status={Enum.at(@statuses, 0)} to={~p"/sok"}>
        Steg 1
      </:step>
      <:step status={Enum.at(@statuses, 1)} to={~p"/sok/edit"}>
        Steg 2
      </:step>
      <:step status={Enum.at(@statuses, 2)} to={~p"/sok/groups"}>
        Steg 3
      </:step>
      <:step status={Enum.at(@statuses, 3)} to={~p"/sok/complete"}>
        Steg 4
      </:step>
    </.steps>
    """
  end
end
