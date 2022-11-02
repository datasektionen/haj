defmodule HajWeb.ApplicationsLive do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Applications

  def mount(_params, _session, socket) do
    current_spex = Spex.current_spex() |> Haj.Repo.preload(show_groups: [group: []])
    applications = Applications.list_applications_for_show(current_spex.id)

    socket =
      socket
      |> assign(:title, "Ansökningar #{current_spex.year.year}")
      |> assign(:show, current_spex)
      |> assign(:applications, applications)

    {:ok, socket}
  end

  def handle_event("filter", %{"filter" => %{"show_group" => show_group_id}}, socket) do
    applications =
      case show_group_id do
        "" -> Applications.list_applications_for_show(socket.assigns.show.id)
        id -> Applications.get_applications_for_show_group(id)
      end

    {:noreply, assign(socket, applications: applications)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col py-2 mb-2 gap-2 md:flex-row md:items-center border-burgandy border-b-2">
      <div class="uppercase font-bold">Filtrera</div>

      <.form :let={f} for={:filter} phx-change="filter" class="w-full md:w-auto">
        <%= select(f, :show_group, group_options(@show.show_groups),
          class: "h-full w-full",
          prompt: "Alla grupper"
        ) %>
      </.form>
    </div>

    <div class="overflow-x-auto pb-6">
      <table class="w-full divide-y divide-gray-200">
        <thead>
          <tr class="text-md font-semibold text-left bg-gray-100 uppercase">
            <%= for col <- ["Namn", "Email", "Telefon", "Klass", "Grupper"] do %>
              <th class="px-4 py-3">
                <%= col %>
              </th>
            <% end %>
          </tr>
        </thead>
        <tbody class="bg-white">
          <%= if @applications == [] do %>
            <td class="pl-6 py-4 whitespace-nowrap text-sm font-medium">Här var det tomt.</td>
          <% else %>
            <%= for {application, i} <- Enum.with_index(@applications) do %>
              <tbody x-data="{show: false}">
                <tr class={
                  if rem(i, 2) == 0,
                    do: "bg-white hover:bg-gray-100",
                    else: "bg-gray-50 hover:bg-gray-100"
                }>
                  <td class="px-4 py-3 border">
                    <div class="flex">
                      <button class="px-2" x-on:click="show = !show">
                        <Heroicons.Solid.chevron_down class="h-6 text-gray-800" />
                      </button>
                      <%= "#{application.user.first_name} #{application.user.last_name}" %>
                    </div>
                  </td>
                  <td class="px-4 py-3 border">
                    <%= application.user.email %>
                  </td>
                  <td class="px-4 py-3 border">
                    <%= application.user.phone %>
                  </td>
                  <td class="px-4 py-3 border">
                    <%= application.user.class %>
                  </td>
                  <td class="px-4 py-3 border">
                    <%= all_groups(application) %>
                  </td>
                </tr>
                <tr x-show="show" class={if rem(i, 2) == 0, do: "bg-white", else: "bg-gray-50"}>
                  <td colspan="5" class="px-4 py-3 gap-2 w-full">
                    <div>Tid för ansökan: <%= application.inserted_at %></div>
                    <div>Övrigt: <%= application.other %></div>
                    <div>Eventuell rangordning: <%= application.ranking %></div>
                    <%= for asg <- application.application_show_groups do %>
                      <%= if asg.show_group.application_extra_question do %>
                        <div>
                          <%= asg.show_group.application_extra_question %>: <%= asg.special_text %>
                        </div>
                      <% end %>
                    <% end %>
                  </td>
                </tr>
              </tbody>
            <% end %>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  defp group_options(show_group) do
    show_group
    # |> Enum.filter(fn %{application_open: open} -> open end) # commented out to only allow SpexM to be applicable
    |> Enum.map(fn %{id: id, group: g} -> [key: g.name, value: id] end)
  end

  defp all_groups(application) do
    Enum.map(application.application_show_groups, fn %{show_group: %{group: group}} ->
      group.name
    end)
    |> Enum.join(", ")
  end
end
