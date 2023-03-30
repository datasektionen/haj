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
    get "/unauthorized", LoginController, :unauthorized
  end

  scope "/live", HajWeb do
    pipe_through :browser

    live_session :authenticated, on_mount: [{HajWeb.UserAuth, :ensure_authenticated}, HajWeb.Nav] do
      live "/", DashboardLive.Index, :index
      live "/unauthorized", DashboardLive.Unauthorized, :index

      live "/user-settings", UserSettingsLive, :index
      live "/members", MembersLive, :index
      live "/user/:username", UserLive, :index
      live "/groups", GroupsLive, :index
      live "/group/:show_group_id", GroupLive, :index

      live "/merch", MerchLive.Index, :index
      live "/merch/new", MerchLive.Index, :new
      live "/merch/:merch_order_item_id/edit", MerchLive.Index, :edit

      live "/merch-admin", MerchAdminLive.Index, :index
      live "/merch-admin/new", MerchAdminLive.Index, :new
      live "/merch-admin/:id/edit", MerchAdminLive.Index, :edit

      live "/events", EventLive.Index, :index
      live "/events/:id", EventLive.Show, :index
    end

    # Admin only!
    live_session :admin, on_mount: [{HajWeb.UserAuth, :ensure_admin}, {HajWeb.Nav, :settings}] do
      scope "/settings" do
        live "/", SettingsLive.Index, :index
        live "/shows", SettingsLive.Show.Index, :index
        live "/shows/new", SettingsLive.Show.Index, :new
        live "/shows/:id/edit", SettingsLive.Show.Index, :edit

        live "/events-admin", EventAdminLive.Index, :index
        live "/events-admin/new", EventAdminLive.Index, :new
        live "/events-admin/:id/edit", EventAdminLive.Index, :edit

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
      end
    end
  end

  scope "/", HajWeb do
    pipe_through [:browser, :require_authenticated_user, :require_spex_access]

    scope "/dashboard" do
      get "/", DashboardController, :index

      # Obsolete
      get "/my-data", DashboardController, :edit_user
      put "/my-data", DashboardController, :update_user

      # Merch stuff, also obsolete
      get "/order-merch", DashboardController, :order_merch
      get "/order-item/new", DashboardController, :new_order_item
      get "/order-item/new/:item_id", DashboardController, :new_order_item
      post "/order-item/new", DashboardController, :create_order_item
      get "/order-item/:id/edit", DashboardController, :edit_order_item
      put "/order-item/:id/edit", DashboardController, :update_order_item
      delete "/order-item/:id", DashboardController, :delete_order_item
    end

    # Obsolete
    get "/user/:username", UserController, :index
    get "/user/:username/groups", UserController, :groups

    # Obsolete
    get "/members", MembersController, :index

    scope "/show-groups" do
      # Obsolete
      get "/", GroupController, :index

      get "/edit/:show_group_id", GroupController, :edit

      # Obsolete
      get "/:show_group_id", GroupController, :group

      get "/:show_group_id/vcard", GroupController, :vcard
      get "/:show_group_id/csv", GroupController, :csv
      get "/:show_group_id/applications", GroupController, :applications
      post "/:show_group_id/accept/:user_id", GroupController, :accept_user
    end

    get "/applications", ApplicationController, :index
    get "/applications/export", ApplicationController, :export

    get "/merch-admin/:show_id", MerchAdminController, :index
    get "/merch-admin/:show_id/orders", MerchAdminController, :orders
    get "/merch-admin/:show_id/csv", MerchAdminController, :csv
    get "/merch-admin/:show_id/new", MerchAdminController, :new
    post "/merch-admin/:show_id/new", MerchAdminController, :create
    get "/merch-admin/:id/edit", MerchAdminController, :edit
    put "/merch-admin/:id/edit", MerchAdminController, :update
    delete "/merch-admin/:show_id/:id", MerchAdminController, :delete
  end

  scope "/settings", HajWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_access]

    get "/", SettingsController, :index
    get "/groups", SettingsController, :groups
    get "/groups/new", SettingsController, :new_group
    post "/groups", SettingsController, :create_group
    get "/groups/:id", SettingsController, :edit_group
    put "/groups/:id", SettingsController, :update_group
    delete "/groups/:id", SettingsController, :delete_group

    get "/show/:show_id/groups", SettingsController, :show_groups
    get "/show-group/:id", SettingsController, :edit_show_group
    delete "/show-group/:id", SettingsController, :delete_show_group
    post "/show/:show_id/groups", SettingsController, :add_show_group

    get "/shows", SettingsController, :shows
    get "/show/new", SettingsController, :new_show
    post "/show", SettingsController, :create_show
    get "/show/:id", SettingsController, :edit_show
    put "/show/:id", SettingsController, :update_show
    get "/show/:id/csv", SettingsController, :csv

    get "/users", SettingsController, :users
    get "/user/new", SettingsController, :new_user
    get "/users/:id", SettingsController, :edit_user
    put "/users/:id", SettingsController, :update_user

    get "/foods", SettingsController, :foods
    get "/foods/new", SettingsController, :new_food
    post "/foods/new", SettingsController, :create_food
    get "/foods/:id", SettingsController, :edit_food
    put "/foods/:id", SettingsController, :update_food
    delete "/foods/:id", SettingsController, :delete_food
  end

  scope "/sok", HajWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", ApplyController, :index
    get "/sucess", ApplyController, :created
    post "/", ApplyController, :apply
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
