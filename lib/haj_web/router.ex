defmodule HajWeb.Router do
  @moduledoc """
  Router for Haj, the internal system.
  """
  use HajWeb, :router

  import HajWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HajWeb.Layouts, :root}
    plug :put_layout, {HajWeb.Layouts, :haj}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HajWeb do
    pipe_through :browser

    get "/login", SessionController, :login
    get "/login/callback", SessionController, :callback
    get "/logout", SessionController, :logout
    get "/login/via-api", SessionController, :login_api

    live_session :default, on_mount: [{HajWeb.UserAuth, :current_user}] do
      live "/signin", SignInLive, :index
    end

    get "/", LoginController, :login
    get "/login/unauthorized", LoginController, :unauthorized
  end

  scope "/", HajWeb do
    pipe_through :browser

    live_session :authenticated,
      on_mount: [
        {HajWeb.UserAuth, :ensure_authenticated},
        {HajWeb.UserAuth, {:authorize, :haj_access}},
        HajWeb.Nav
      ] do
      live "/dashboard", DashboardLive.Index, :index
      live "/unauthorized", DashboardLive.Unauthorized, :index

      live "/user-settings", UserSettingsLive, :index
      live "/members", MembersLive, :index
      live "/user/:username", UserLive, :index

      ## Groups
      live "/groups", GroupLive.Index, :index
      live "/group/:show_group_id", GroupLive.Show, :show
      live "/group/admin/:show_group_id", GroupLive.Admin, :index

      ## Merch
      live "/merch", MerchLive.Index, :index
      live "/merch/new", MerchLive.Index, :new
      live "/merch/:merch_order_item_id/edit", MerchLive.Index, :edit

      ## Merch admin

      live "/merch-admin", MerchAdminLive.Index, :index
      live "/merch-admin/new", MerchAdminLive.Index, :new
      live "/merch-admin/:id/edit", MerchAdminLive.Index, :edit
      live "/merch-admin/orders", MerchAdminLive.Orders, :index

      ## Responsibilities

      live "/responsibilities", ResponsibilityLive.Index, :index
      live "/responsibilities/history", ResponsibilityLive.History, :index
      live "/responsibilities/new", ResponsibilityLive.Index, :new
      live "/responsibilities/:id/edit", ResponsibilityLive.Index, :edit

      live "/responsibilities/:id", ResponsibilityLive.Show, :show
      live "/responsibilities/:id/comments", ResponsibilityLive.Show, :comments

      live "/responsibilities/:id/comments/:comment_id/edit",
           ResponsibilityLive.Show,
           :edit_comment

      live "/responsibilities/:id/history", ResponsibilityLive.Show, :history
      live "/responsibilities/:id/show/edit", ResponsibilityLive.Show, :edit

      ## Applications
      live "/applications", ApplicationsLive.Index, :index
      live "/applications/:id", ApplicationsLive.Show, :show
      live "/applications/:id/confirm", ApplicationsLive.Show, :approve

      ## Songs
      live "/songs", SongLive.Index, :index
      live "/songs/:id", SongLive.Show, :show

      ## Shows
      live "/shows", ShowLive.Index, :index
      live "/shows/:show_id", ShowLive.Show, :index

      ## Events
      live "/events", EventLive.Index, :index
      live "/events/:id", EventLive.Show, :index

      live "/forms/:id", FormLive.Index, :index
    end

    # Admin only!
    live_session :admin,
      on_mount: [
        {HajWeb.UserAuth, :ensure_authenticated},
        {HajWeb.UserAuth, {:authorize, :settings_admin}},
        {HajWeb.Nav, :settings}
      ] do
      scope "/settings" do
        live "/", SettingsLive.Index, :index
        live "/shows", SettingsLive.Show.Index, :index
        live "/shows/new", SettingsLive.Show.Index, :new
        live "/shows/:id/edit", SettingsLive.Show.Index, :edit

        live "/events", SettingsLive.Event.Index, :index
        live "/events/new", SettingsLive.Event.Index, :new
        live "/events/:id/edit", SettingsLive.Event.Index, :edit

        live "/shows/:id", SettingsLive.Show.Show, :show
        live "/shows/:id/show/edit", SettingsLive.Show.Show, :edit

        live "/shows/:id/show-groups/:show_group_id/edit",
             SettingsLive.Show.Show,
             :edit_show_group

        live "/groups", SettingsLive.Group.Index, :index
        live "/groups/new", SettingsLive.Group.Index, :new
        live "/groups/:id/edit", SettingsLive.Group.Index, :edit
        live "/groups/:id", SettingsLive.Group.Show, :show
        live "/groups/:id/show/edit", SettingsLive.Group.Show, :edit

        live "/groups/:id/show-groups/new", SettingsLive.Group.Show, :new_show_group

        live "/groups/:id/show-groups/:show_group_id/edit",
             SettingsLive.Group.Show,
             :edit_show_group

        live "/foods", SettingsLive.Food.Index, :index
        live "/foods/new", SettingsLive.Food.Index, :new
        live "/foods/:id/edit", SettingsLive.Food.Index, :edit

        live "/foods/:id", SettingsLive.Food.Show, :show
        live "/foods/:id/show/edit", SettingsLive.Food.Show, :edit

        live "/users", SettingsLive.User.Index, :index
        live "/users/:id/edit", SettingsLive.User.Index, :edit

        live "/responsibilities", SettingsLive.Responsibility.Index, :index
        live "/responsibilities/new", SettingsLive.Responsibility.Index, :new
        live "/responsibilities/:id/edit", SettingsLive.Responsibility.Index, :edit

        live "/responsibilities/:id", SettingsLive.Responsibility.Show, :show

        live "/responsibilities/:id/new-responsible",
             SettingsLive.Responsibility.Show,
             :new_responsible

        live "/responsibilities/:id/show/edit", SettingsLive.Responsibility.Show, :edit

        live "/songs", SettingsLive.Song.Index, :index
        live "/songs/new", SettingsLive.Song.Index, :new
        live "/songs/:id/edit", SettingsLive.Song.Index, :edit

        live "/songs/:id", SettingsLive.Song.Show, :show
        live "/songs/:id/show/edit", SettingsLive.Song.Show, :edit

        live "/forms", SettingsLive.Form.Index, :index
        live "/forms/new", SettingsLive.Form.Index, :new
        live "/forms/:id/edit", SettingsLive.Form.Index, :edit

        live "/forms/:id", SettingsLive.Form.Show, :show
        live "/forms/:id/show/edit", SettingsLive.Form.Show, :edit
      end
    end
  end

  scope "/", HajWeb do
    pipe_through [:browser, :require_authenticated_user, :require_spex_access]

    post "/group/:show_group_id/csv", GroupController, :csv
    post "/group/:show_group_id/vcard", GroupController, :vcard

    post "/merch-admin/:show_id/csv", MerchAdminController, :csv

    pipeline :require_applications_read do
      plug :require_auth, :applications_read
    end

    scope "/" do
      pipe_through :require_applications_read

      #   get "/applications", ApplicationController, :index
      get "/applications/export/csv", ApplicationController, :export
    end
  end

  scope "/sok", HajWeb do
    pipe_through [:browser]

    live "/", ApplyLive.Index, :index
    live "/edit", ApplyLive.EditInfo, :edit
    live "/groups", ApplyLive.Groups, :groups
    live "/complete", ApplyLive.Complete, :groups
    live "/success", ApplyLive.Success, :created
  end

  # Other scopes may use custom stacks.
  # scope "/api", HajWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/live-dashboard", metrics: HajWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
