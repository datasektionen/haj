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
        <div class={"rounded-md #{if @active_tab == :groups, do: "bg-burgandy-600"}" }>
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

        <.nav_link
          navigate={~p"/live/responsibilities"}
          icon_name={:briefcase}
          title="Ansvar"
          active={@active_tab == :responsibilities}
        />
      <% end %>
    </div>
    """
  end

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={"text-white group flex items-center px-2 py-2 rounded-md #{if @active, do: "bg-burgandy-600"}"}
    >
      <.icon name={@icon_name} solid class=" mr-3 flex-shrink-0 h-6 w-6" />
      <%= @title %>
    </.link>
    """
  end

  # Link for a show group, should be indented and whtihout a logo
  def nav_group_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={"text-burgandy-100 flex items-center pl-11 px-2 py-2 rounded-md #{if @active, do: "bg-burgandy-600"}"}
    >
      <%= @title %>
    </.link>
    """
  end

  def user_dropdown(assigns) do
    ~H"""
    <div class="bg-white relative flex flex-col border rounded-md">
      <%!-- CSS magic taken from github website --%>
      <.link
        navigate={Routes.user_path(Endpoint, :index, @user.username)}
        class="px-4 py-2 border-b hover:bg-burgandy-500 hover:text-white rounded-t-md hover:after:border-b-burgandy-500
                      before:border-8 before:border-transparent before:absolute before:-top-[16px] before:right-[10px] before:border-b-gray-200
                      after:border-[7px] after:border-transparent after:absolute after:-top-[14px] after:right-[11px] after:border-b-white"
      >
        Min profil
      </.link>
      <.link
        navigate={Routes.user_settings_path(Endpoint, :index)}
        class="px-4 py-2 border-b hover:bg-burgandy-500 hover:text-white"
      >
        Mina uppgifter
      </.link>
      <.link class="px-4 py-2 border-b hover:bg-burgandy-500 hover:text-white rounded-b-md">
        Inställningar
      </.link>
      <.link
        navigate={~p"/logout"}
        class="px-4 py-2 hover:bg-burgandy-500 hover:text-white rounded-b-md"
      >
        Logga ut
      </.link>
    </div>
    """
  end
end
