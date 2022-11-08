defmodule HajWeb.DashboardLive do
  use HajWeb, :live_view

  alias Haj.Spex
  alias HajWeb.Endpoint

  def mount(_params, _session, socket) do
    current_show = Spex.current_spex()

    user_groups =
      Spex.get_show_groups_for_user(socket.assigns.current_user.id)
      |> Enum.filter(fn %{show: show} -> show.id == current_show.id end)

    {:ok, assign(socket, user_groups: user_groups)}
  end

  def render(assigns) do
    ~H"""
    <div class="font-bold text-3xl pt-4">
      <h3 class="inline-block">Hej,</h3>
      <h3 class="inline-block text-burgandy-600"><%= @current_user.first_name %>!</h3>
    </div>
    <p class="text-gray-500 text-sm pt-2">
      Välkommen till Haj, METAspexets interna system! Detta system är fortfarade under utveckling. Idéer eller tankar? Hör av dig till Webbchef Adrian på
      <a href="mailto:webb@metaspexet.se" class="font-bold text-burgandy-600">mail</a>
      eller Slack!
    </p>
    <div class="py-4">
      <h3 class="text-2xl font-bold pt-2 pb-4">Dina grupper</h3>
      <div class="grid sm:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
        <%= for show_group <- @user_groups do %>
          <.group_card
            show_group={show_group}
            role={
              Enum.find(show_group.group_memberships, fn %{user_id: user_id} ->
                user_id == @current_user.id
              end).role
            }
          />
        <% end %>
      </div>
    </div>
    """
  end

  defp group_card(assigns) do
    ~H"""
    <.link
      navigate={Routes.group_path(Endpoint, :index, @show_group.id)}
      class="flex flex-col gap-1 sm:gap-1.5 border rounded-lg px-4 py-4 hover:bg-gray-50"
    >
      <div class="text-lg font-bold text-burgandy-500 inline-flex items-center gap-2">
        <.icon name={:user_group} />
        <span class="">
          <%= @show_group.group.name %>
        </span>
      </div>
      <div class="text-gray-500">
        <%= length(@show_group.group_memberships) %> medlemmar
      </div>
      <div>
        Du är <%= @role %>
      </div>
    </.link>
    """
  end
end
