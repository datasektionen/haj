defmodule HajWeb.GroupLive do
  use HajWeb, :live_view

  alias Haj.Spex
  alias HajWeb.Endpoint

  def mount(%{"show_group_id" => show_group_id}, _session, socket) do
    show_group = Spex.get_show_group!(show_group_id)

    {:ok, assign(socket, group: show_group)}
  end

  def render(assigns) do
    ~H"""
    <div class="mt-4 flex flex-col gap-4 justify-start xl:flex-row lg:px-6 lg:py-6 xl:items-center xl:gap-12 lg:border lg:rounded-lg">
      <div class="flex-shrink-0 flex flex-col gap-2 sm:flex-row sm:gap-12 xl:items-center">
        <div class="">
          <h3 class="font-bold text-2xl">
            <%= @group.group.name %>
          </h3>
          <span class="text-sm text-gray-600">Del av METAspexet <%= @group.show.year.year %></span>
        </div>
        <div class="">
          <h4 class="font-bold text-l">Ansvariga chefer</h4>
          <div class="flex flex-col gap-2 pt-2">
            <%= for chef <- chefer(@group) do %>
              <.link navigate={Routes.user_path(Endpoint, :index, chef.username)} class="group">
                <img
                  src={"https://zfinger.datasektionen.se/user/#{chef.username}/image/100"}
                  class="h-6 w-6 rounded-full object-cover object-top inline-block filter group-hover:brightness-90"
                />
                <span class="text-gray-700 text-sm px-2 group-hover:text-gray-900">
                  <%= full_name(chef) %>
                </span>
              </.link>
            <% end %>
          </div>
        </div>
      </div>
      <div class="">
        <%= if @group.application_description do %>
          <h4 class="font-bold text-l">Vad gör <%= @group.group.name %>?</h4>
          <p class="text-sm whitespace-pre-wrap"><%= @group.application_description %></p>
        <% end %>
      </div>
    </div>
    <div class="pt-6 pb-4">
      <div class="flex flex-row items-center pb-2">
        <div class="flex flex-col">
          <span class="text-xl font-bold ">Alla Medlemmar</span>
          <span class="text-sm text-gray-500 ">Totalt <%= length(@group.group_memberships) %></span>
        </div>
        <.link
          href={Routes.group_path(Endpoint, :vcard, @group.id)}
          class="ml-auto flex flex-row items-center gap-2 border rounded-lg px-3 py-2
                 hover:bg-gray-50"
        >
          <.icon name={:arrow_down_on_square_stack} mini class="h-5 w-5" />
          <span class="text-sm">Ladda ner vcard</span>
        </.link>
      </div>

      <.live_table rows={@group.group_memberships |> Enum.map(fn %{user: user} -> user end)}>
        <:col :let={member} label="Namn">
          <.user_card user={member} />
        </:col>
        <:col :let={member} label="KTH-id" class="hidden xs:table-cell">
          <%= member.username %>
        </:col>
        <:col :let={member} label="Klass" class="hidden sm:table-cell">
          <%= member.class %>
        </:col>
        <:col :let={member} label="Telefonnr">
          <%= member.phone %>
        </:col>
        <:col :let={member} label="Mail" class="hidden lg:table-cell">
          <%= member.email %>
        </:col>
        <:col :let={member} label="Google-konto" class="hidden xl:table-cell">
          <%= member.google_account %>
        </:col>
      </.live_table>
    </div>
    """
  end

  defp chefer(show_group) do
    Enum.filter(show_group.group_memberships, fn %{role: role} -> role == :chef end)
    |> Enum.map(fn %{user: user} ->
      user
    end)
  end
end
