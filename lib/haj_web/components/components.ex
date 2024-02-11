defmodule HajWeb.Components do
  use Phoenix.Component
  use HajWeb, :verified_routes

  embed_templates "components/*"

  import HajWeb.CoreComponents

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

  @doc """
  A generic card component with a title, subtitle and inner block.
  """
  attr :navigate, :any, required: true
  slot :title, required: true
  slot :subtitle
  slot :inner_block, required: true

  def generic_card(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class="flex flex-col gap-1 rounded-lg border bg-white px-4 py-4 shadow-sm duration-150 hover:bg-gray-50 sm:gap-1.5"
    >
      <div class="text-burgandy-500 inline-flex items-center gap-2 text-lg font-bold">
        <%= render_slot(@title) %>
      </div>

      <div :if={@subtitle != []} class="text-gray-500">
        <%= render_slot(@subtitle) %>
      </div>

      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  ## Form component

  attr :question, :any, required: true
  attr :field, :any, required: true

  def form_input(%{question: %{type: :select}} = assigns) do
    ~H"""
    <.input field={@field} type="select" options={@question.options} label={@question.name} />
    """
  end

  def form_input(%{question: %{type: :multi_select}} = assigns) do
    ~H"""
    <label class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= @question.name %>
    </label>
    <div :for={option <- @question.options}>
      <.input
        name={"#{@field.name}[#{option}]"}
        type="checkbox"
        value={option in Ecto.Changeset.get_field(assigns.field.form.source, assigns.field.field, [])}
        label={option}
      />
    </div>
    """
  end

  def form_input(assigns) do
    ~H"""
    <.input field={@field} type="text" label={@question.name} />
    """
  end
end
