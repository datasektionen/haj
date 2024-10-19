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

  slot :subtitle do
    attr :class, :string
  end

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

  @doc """
  A generic form component that works with Changesets generated from Haj.Form.

  Question types are: :select, :multi_select, :text_area, :text
  """

  attr :question, :any, required: true
  attr :field, :any, required: true
  attr :class, :string, default: ""

  def form_input(%{question: %{type: :select}} = assigns) do
    ~H"""
    <div class={@class}>
      <.input field={@field} type="select" options={@question.options} label={@question.name} />
    </div>
    """
  end

  def form_input(%{question: %{type: :multi_select}} = assigns) do
    ~H"""
    <div class={@class}>
      <label class="block text-sm font-semibold leading-6 text-zinc-800">
        <%= @question.name %>
      </label>
      <div class="mt-2 flex flex-col gap-1">
        <div :for={option <- @question.options}>
          <.input
            name={"#{@field.name}[#{option}]"}
            type="checkbox"
            value={
              option in Ecto.Changeset.get_field(assigns.field.form.source, assigns.field.field, [])
            }
            label={option}
          />
        </div>
        <.error :for={msg <- Enum.map(assigns.field.errors, &translate_error(&1))}><%= msg %></.error>
      </div>
    </div>
    """
  end

  def form_input(%{question: %{type: :text_area}} = assigns) do
    ~H"""
    <div class={@class}>
      <.input field={@field} type="textarea" label={@question.name} />
    </div>
    """
  end

  def form_input(assigns) do
    ~H"""
    <div class={@class}>
      <.input field={@field} type="text" label={@question.name} />
    </div>
    """
  end

  @doc """
  A generic stats card component with a title and value.
  """
  attr :title, :string, required: true
  attr :value, :string, required: true

  def stats_card(assigns) do
    ~H"""
    <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
      <dt class="truncate text-sm font-medium text-gray-500"><%= @title %></dt>
      <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
        <%= @value %>
      </dd>
    </div>
    """
  end
end
