defmodule HajWeb.EventLive.Registrations.Show do
  use HajWeb, :live_view

  alias Haj.Events
  alias Haj.Spex

  @impl Phoenix.LiveView
  def mount(%{"id" => registration_id}, _session, socket) do
    registration = Events.get_event_registration!(registration_id)
    group_memberships = Spex.get_show_groups_for_user(registration.user_id)

    {:ok,
     assign(socket,
       registration: registration,
       memberships: group_memberships,
       page_title: "Anmälan"
     )}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row justify-between px-4 sm:px-0">
        <div>
          <h3 class="text-2xl font-bold leading-7 text-gray-900">Anmälan</h3>
          <p class="mt-1 max-w-2xl text-sm leading-6 text-gray-500">
            Till eventet <%= @registration.event.name %>
          </p>
        </div>
      </div>

      <div class="mt-6">
        <dl class="grid grid-cols-1 border-t-2 border-gray-100 sm:grid-cols-2">
          <.field name="Person" top>
            <.user_card user={@registration.user} />
          </.field>
          <.field name="Klass" top>
            <%= @registration.user.class %>
          </.field>
          <.field name="Email">
            <%= @registration.user.email %>
          </.field>
          <.field name="Telefon">
            <%= @registration.user.phone %>
          </.field>
          <.field name="Tid för anmälan">
            <%= @registration.updated_at %>
          </.field>
          <.field name="Grupper">
            <div class="flex max-w-sm flex-wrap items-center gap-1">
              <.link :for={show_group <- @memberships} navigate={~p"/group/#{show_group}"}>
                <div
                  class="rounded-full px-2 py-0.5 filter hover:brightness-90"
                  style={"background-color: #{get_color(:bg, show_group.group.id)};
                      color: #{pick_text_color(get_color(:bg, show_group.group.id))};"}
                >
                  <%= show_group.group.name %>
                </div>
              </.link>
            </div>
          </.field>
        </dl>
      </div>

      <div class="mt-6 flex flex-row justify-between px-4 sm:px-0">
        <div>
          <h3 class="text-2xl font-bold leading-7 text-gray-900">Formulärsvar</h3>
          <p class="mt-1 max-w-2xl text-sm leading-6 text-gray-500">
            Alla svar som användaren har fyllt i.
          </p>
        </div>
      </div>

      <div class="mt-6">
        <dl class="grid grid-cols-1 border-t-2 border-gray-100 sm:grid-cols-2">
          <.field large name="Kommer på eventet?" top>
            <%= format_bool(@registration.attending) %>
          </.field>

          <.field :for={qr <- @registration.response.question_responses} large name={qr.question.name}>
            <%= qr.answer %>
          </.field>
        </dl>
      </div>
    </div>
    """
  end

  attr(:large, :boolean, default: false)
  attr(:top, :boolean, default: false)
  attr(:name, :string)
  slot(:inner_block)

  defp field(assigns) do
    ~H"""
    <div class={[
      "px-4 py-6 sm:px-0",
      @top || "border-t border-gray-100",
      @large || "sm:col-span-1",
      @large && "sm:col-span-2"
    ]}>
      <dt class="text-sm font-medium leading-6 text-gray-900"><%= @name %></dt>
      <dd class="mt-1 text-sm leading-6 text-gray-700 sm:mt-2">
        <%= render_slot(@inner_block) %>
      </dd>
    </div>
    """
  end

  defp format_bool(true), do: "Ja"
  defp format_bool(false), do: "Nej"
end
