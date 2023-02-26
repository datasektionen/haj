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

        <.nav_link_group
          navigate={~p"/live/groups"}
          icon_name={:user_group}
          title="Grupper"
          active={@active_tab == :groups}
          expanded={any_group_active(@current_user.group_memberships, @active_tab)}
        >
          <:sub_link
            :for={g <- @current_user.group_memberships}
            navigate={~p"/live/group/#{g.show_group}"}
            title={g.show_group.group.name}
            active={@active_tab == {:group, g.show_group_id}}
          />
        </.nav_link_group>

        <.nav_link_group
          :if={@current_user.role == :admin}
          navigate={~p"/live/settings"}
          icon_name={:cog_6_tooth}
          title="Inställningar"
          active={@active_tab == :settings}
          expanded={@expanded_tab == :settings}
        >
          <:sub_link
            navigate={~p"/live/settings/shows"}
            title="Spex"
            active={@active_tab == {:setting, :shows}}
          />
        </.nav_link_group>
      <% end %>
    </div>
    """
  end

  defp any_group_active(group_memberships, active_tab) do
    active_tab == :groups ||
      Enum.any?(group_memberships, fn g ->
        active_tab == {:group, g.show_group_id}
      end)
  end

  attr :active, :boolean, default: false
  attr :expanded, :boolean, default: false
  attr :navigate, :any, required: true
  attr :icon_name, :atom, required: true
  attr :title, :string, required: true

  slot :sub_link do
    attr :navigate, :any, required: true
    attr :title, :string, required: true
    attr :active, :boolean
  end

  def nav_link_group(assigns) do
    ~H"""
    <div class={"rounded-md #{if @expanded, do: "bg-burgandy-600/50"}"}>
      <.link
        navigate={@navigate}
        class={[
          "text-white hover:text-burgandy-700 hover:bg-burgandy-50 flex items-center px-2 py-2 rounded-md",
          @active && "bg-burgandy-600"
        ]}
      >
        <.icon name={@icon_name} solid class="mr-3 flex-shrink-0 h-6 w-6" />
        <%= @title %>
      </.link>
      <div :for={sub_link <- @sub_link} :if={@expanded}>
        <.link
          navigate={sub_link.navigate}
          class={[
            "text-burgandy-100 hover:text-burgandy-700 hover:bg-burgandy-50 flex items-center pl-11 px-2 py-2 rounded-md",
            Map.get(sub_link, :active, false) && "bg-burgandy-600"
          ]}
        >
          <%= sub_link.title %>
        </.link>
      </div>
    </div>
    """
  end

  def nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={"text-white hover:text-burgandy-700 hover:bg-burgandy-50 flex items-center px-2 py-2 rounded-md #{if @active, do: "bg-burgandy-600"}"}
    >
      <.icon name={@icon_name} solid class="mr-3 flex-shrink-0 h-6 w-6" />
      <%= @title %>
    </.link>
    """
  end

  # Link for a show group, should be indented and whtihout a logo
  def nav_group_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={"text-burgandy-100 hover:text-burgandy-700 hover:bg-burgandy-50 flex items-center pl-11 px-2 py-2 rounded-md #{if @active, do: "bg-burgandy-600"}"}
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
      <.link class="px-4 py-2 border-b hover:bg-burgandy-500 hover:text-white">
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
