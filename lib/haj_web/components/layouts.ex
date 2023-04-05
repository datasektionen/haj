defmodule HajWeb.Layouts do
  use HajWeb, :html
  require Logger

  embed_templates "layouts/*"

  alias Haj.Policy
  alias HajWeb.Endpoint

  def sidebar_nav_links(assigns) do
    ~H"""
    <div :if={@current_user && Policy.authorize?(:haj_access, @current_user)} class="space-y-1">
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
        :if={Policy.authorize?(:responsibility_read, @current_user)}
        navigate={~p"/live/responsibilities"}
        icon_name={:briefcase}
        title="Ansvar"
        active={@active_tab == :responsibilities}
        expanded={@active_tab in [:responsibilities, :responsibility_history]}
      >
        <:sub_link
          navigate={~p"/live/responsibilities/history"}
          title="Dina ansvar"
          active={@active_tab == :responsibility_history}
        />
      </.nav_link_group>

      <.nav_link_group
        navigate={~p"/live/merch"}
        icon_name={:shopping_cart}
        title="Merch"
        active={@active_tab == :merch}
        expanded={@active_tab in [:merch, :merch_admin, :merch_orders]}
      >
        <:sub_link
          :if={Policy.authorize?(:merch_admin, @current_user)}
          navigate={~p"/live/merch-admin/"}
          title="Administrera"
          active={@active_tab == :merch_admin}
        />

        <:sub_link
          :if={Policy.authorize?(:merch_list_orders, @current_user)}
          navigate={~p"/live/merch-admin/orders"}
          title="Beställningar"
          active={@active_tab == :merch_orders}
        />
      </.nav_link_group>

      <.nav_link_group
        :if={Policy.authorize?(:settings_admin, @current_user)}
        navigate={~p"/live/settings"}
        icon_name={:cog_6_tooth}
        title="Administrera"
        active={@active_tab == :settings}
        expanded={@expanded_tab == :settings}
      >
        <:sub_link
          navigate={~p"/live/settings/shows"}
          title="Spex"
          active={@active_tab == {:setting, :shows}}
        />

        <:sub_link
          navigate={~p"/live/settings/groups"}
          title="Grupper"
          active={@active_tab == {:setting, :groups}}
        />

        <:sub_link
          navigate={~p"/live/settings/foods"}
          title="Mat"
          active={@active_tab == {:setting, :foods}}
        />

        <:sub_link
          navigate={~p"/live/settings/users"}
          title="Användare"
          active={@active_tab == {:setting, :users}}
        />

        <:sub_link
          navigate={~p"/live/settings/responsibilities"}
          title="Ansvar"
          active={@active_tab == {:setting, :responsibilities}}
        />
      </.nav_link_group>
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
    <div class={"#{if @expanded, do: "bg-burgandy-600/50"} rounded-md"}>
      <.link
        navigate={@navigate}
        class={[
          "text-white hover:text-burgandy-700 hover:bg-burgandy-50 flex items-center px-2 py-2 rounded-md",
          @active && "bg-burgandy-600"
        ]}
      >
        <.icon name={@icon_name} solid class="mr-3 h-6 w-6 flex-shrink-0" />
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
