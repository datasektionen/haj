defmodule HajWeb.Layouts do
  use HajWeb, :html
  require Logger

  embed_templates "layouts/*"

  alias HajWeb.Endpoint

  def sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= if @current_user && Enum.member?([:admin, :chef, :spexare], @current_user.role) do %>
        <.nav_link
          navigate={~p"/live"}
          icon_name={:home}
          title="Min sida"
          active={@active_tab == :dashboard}
        />
        <.nav_link
          navigate={~p"/live/members"}
          icon_name={:user}
          title="Medlemmar"
          active={@active_tab == :members}
        />
        <div class={"#{if @active_tab == :groups, do: "bg-burgandy-600"} rounded-md"} }>
          <.nav_link
            navigate={~p"/live/groups"}
            icon_name={:user_group}
            title="Grupper"
            active={@active_tab == :groups}
          />
          <%= for g <- @current_user.group_memberships do %>
            <.nav_group_link
              navigate={~p"/live/group/#{g.show_group}"}
              title={g.show_group.group.name}
              active={@active_tab == {:group, g.show_group_id}}
            />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={"#{if @active, do: "bg-burgandy-600"} flex items-center rounded-md px-2 py-2 text-white hover:text-burgandy-700 hover:bg-burgandy-50"}
    >
      <.icon name={@icon_name} solid class="mr-3 h-6 w-6 flex-shrink-0" />
      <%= @title %>
    </.link>
    """
  end

  # Link for a show group, should be indented and whtihout a logo
  def nav_group_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={"#{if @active, do: "bg-burgandy-600"} text-burgandy-100 flex items-center rounded-md px-2 py-2 pl-11 hover:text-burgandy-700 hover:bg-burgandy-50"}
    >
      <%= @title %>
    </.link>
    """
  end

  def user_dropdown(assigns) do
    ~H"""
    <div class="relative flex flex-col rounded-md border bg-white">
      <%!-- CSS magic taken from github website --%>
      <.link
        navigate={Routes.user_path(Endpoint, :index, @user.username)}
        class="rounded-t-md border-b px-4 py-2 before:-top-[16px] before:right-[10px] before:absolute before:border-8 before:border-transparent before:border-b-gray-200 after:border-[7px] after:-top-[14px] after:right-[11px] after:absolute after:border-transparent after:border-b-white hover:bg-burgandy-500 hover:text-white hover:after:border-b-burgandy-500"
      >
        Min profil
      </.link>
      <.link
        navigate={Routes.user_settings_path(Endpoint, :index)}
        class="border-b px-4 py-2 hover:bg-burgandy-500 hover:text-white"
      >
        Mina uppgifter
      </.link>
      <.link class="border-b px-4 py-2 hover:bg-burgandy-500 hover:text-white">
        Inställningar
      </.link>
      <.link
        navigate={~p"/logout"}
        class="rounded-b-md px-4 py-2 hover:bg-burgandy-500 hover:text-white"
      >
        Logga ut
      </.link>
    </div>
    """
  end
end
