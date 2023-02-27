defmodule HajWeb.SettingsLive.Index do
  use HajWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Inställningar
        <:subtitle>
          Välj sak att administrera. Användargränssnittet fungerar bäst på en dator.
        </:subtitle>
      </.header>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 pt-4">
        <.setting_card name="Spex" navigate={~p"/live/settings/shows"}>
          Redigera alla spex
        </.setting_card>
        <.setting_card name="Grupper" navigate={~p"/live/settings/groups"}>
          Redigera årsöverskridande spexgrupper
        </.setting_card>
        <.setting_card name="Mat" navigate={~p"/live/settings/foods"}>
          Redigera matpreferenser
        </.setting_card>
      </div>
    </div>
    """
  end

  attr :navigate, :any, required: true
  attr :name, :string, required: true
  slot :inner_block

  defp setting_card(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class="flex flex-col gap-1 sm:gap-1.5 border rounded-lg px-4 py-4 hover:bg-gray-50"
    >
      <div class="text-lg font-bold text-burgandy-500">
        <%= @name %>
      </div>
      <div class="text-sm">
        <%= render_slot(@inner_block) %>
      </div>
    </.link>
    """
  end
end
