defmodule HajWeb.ApplicationsLive.Show do
  use HajWeb, :live_view

  alias Haj.Applications
  alias Haj.Repo

  on_mount {HajWeb.UserAuth, {:authorize, :applications_read}}

  def mount(%{"id" => id}, _session, socket) do
    application =
      Applications.get_application!(id)
      |> Repo.preload(application_show_groups: [show_group: [:group]], user: [])

    show = Haj.Spex.current_spex()

    {:ok, assign(socket, application: application, show: show)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params), do: assign(socket, :page_title, "Ansökan")
  defp apply_action(socket, :approve, _params), do: assign(socket, :page_title, "Antag")

  attr :large, :boolean, default: false
  attr :name, :string
  slot :inner_block

  defp field(assigns) do
    ~H"""
    <div class={[
      "border-t border-gray-100 px-4 py-6 sm:px-0",
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
end
