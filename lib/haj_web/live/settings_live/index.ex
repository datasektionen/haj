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

      <div class="grid grid-cols-1 gap-6 pt-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        <.setting_card name="Spex" navigate={~p"/settings/shows"}>
          Redigera alla spex
        </.setting_card>
        <.setting_card name="Grupper" navigate={~p"/settings/groups"}>
          Redigera grupper och spexgrupper
        </.setting_card>
        <.setting_card name="Mat" navigate={~p"/settings/foods"}>
          Redigera matpreferenser
        </.setting_card>
        <.setting_card name="Användare" navigate={~p"/settings/users"}>
          Redigera användare och användaruppgifter
        </.setting_card>
        <.setting_card name="Ansvar" navigate={~p"/settings/responsibilities"}>
          Redigera ansvar
        </.setting_card>
        <.setting_card name="Sånger" navigate={~p"/settings/songs"}>
          Redigera sånger
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
      class="flex flex-col gap-1 rounded-lg border px-4 py-4 hover:bg-gray-50 sm:gap-1.5"
    >
      <div class="text-burgandy-500 text-lg font-bold">
        <%= @name %>
      </div>
      <div class="text-sm">
        <%= render_slot(@inner_block) %>
      </div>
    </.link>
    """
  end
end
