defmodule HajWeb.ApplicationsLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Applications

  on_mount({HajWeb.UserAuth, {:authorize, :applications_read}})

  def mount(_params, _session, socket) do
    current_spex = Spex.current_spex() |> Haj.Repo.preload(show_groups: [group: []])
    applications = Applications.list_applications_for_show(current_spex.id)

    most_popular_groups =
      case applications do
        [] ->
          [%Spex.Group{name: "Inga ansökningar"}]

        apps ->
          groups =
            apps
            |> Enum.flat_map(fn app -> app.application_show_groups end)
            |> Enum.group_by(fn asg -> asg.show_group_id end)
            |> Enum.map(fn {_, asgs} -> {hd(asgs).show_group.group, length(asgs)} end)

          {_, max_count} = Enum.max_by(groups, &elem(&1, 1))

          Enum.filter_map(groups, fn {_, count} -> count == max_count end, fn {group, _} ->
            group
          end)
      end

    stats = %{
      apps: length(applications),
      group_apps:
        Enum.reduce(applications, 0, fn app, acc -> acc + length(app.application_show_groups) end),
      most_popular_groups: Enum.map_join(most_popular_groups, ", ", & &1.name)
    }

    {:ok,
     socket
     |> assign(:page_title, "Ansökningar")
     |> assign(:show, current_spex)
     |> assign(:applications, applications)
     |> assign(:stats, stats)
     |> assign(:selected, "")}
  end

  def handle_params(%{"show_group_id" => id}, _uri, socket) do
    applications = Applications.get_applications_for_show_group(id)
    {:noreply, assign(socket, applications: applications, selected: id)}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  def handle_event("filter", %{"show_group" => show_group_id}, socket) do
    case show_group_id do
      "" ->
        apps = Applications.list_applications_for_show(socket.assigns.show.id)

        {:noreply,
         assign(socket, applications: apps)
         |> push_patch(to: ~p"/applications")}

      id ->
        apps = Applications.get_applications_for_show_group(id)

        {:noreply,
         assign(socket, applicatons: apps)
         |> push_patch(to: ~p"/applications?show_group_id=#{show_group_id}")}
    end
  end

  defp group_options(show_group) do
    show_group
    # |> Enum.filter(fn %{application_open: open} -> open end) # commented out to only allow SpexM to be applicable
    |> Enum.map(fn %{id: id, group: g} -> [key: g.name, value: id] end)
  end
end
