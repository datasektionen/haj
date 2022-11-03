defmodule HajWeb.LayoutView do
  use HajWeb, :view

  alias HajWeb.Endpoint

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= if @current_user && Enum.member?([:admin, :chef, :spexare], @current_user.role) do %>
        <.nav_link
          navigate={Routes.dashboard_path(Endpoint, :index)}
          icon_name={:home}
          title="Min sida"
          }
        />
        <.nav_link
          navigate={Routes.members_path(Endpoint, :index)}
          icon_name={:user}
          title="Medlemmar"
          }
        />
        <.nav_link
          navigate={Routes.group_path(Endpoint, :index)}
          icon_name={:user_group}
          title="Grupper"
          }
        />
      <% end %>
    </div>
    """
  end

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class="text-gray-700 hover:text-gray-900 hover:bg-gray-50 group flex items-center px-2 py-2 rounded-md"
    >
      <.icon
        name={@icon_name}
        class="text-gray-700 group-hover:text-gray-900 mr-3 flex-shrink-0 h-6 w-6"
      /> <%= @title %>
    </.link>
    """
  end
end
