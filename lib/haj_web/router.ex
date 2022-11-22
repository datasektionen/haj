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

    live_session :default, on_mount: [{HajWeb.UserAuth, :current_user}] do
      live "/signin", SignInLive, :index
    end

    get "/", LoginController, :login
    get "/unauthorized", LoginController, :unauthorized
  end

  scope "/live", HajWeb do
    pipe_through :browser

    live_session :authenticated, on_mount: [{HajWeb.UserAuth, :ensure_authenticated}] do
      live "/", DashboardLive, :index
      live "/user-settings", UserSettingsLive, :index
      live "/members", MembersLive, :index
      live "/user/:username", UserLive, :index
      live "/groups", GroupsLive, :index
      live "/group/:show_group_id", GroupLive, :index

      live "/merch-admin", MerchAdminLive.Index, :index
      live "/merch-admin/new", MerchAdminLive.Index, :new
      live "/merch-admin/:id/edit", MerchAdminLive.Index, :edit

      live "/events", EventLive.Index, :index
      live "/events/new", EventLive.Index, :new
      live "/events/:id/edit", EventLive.Index, :edit

      live "/events/:id", EventLive.Show, :show
      live "/events/:id/show/edit", EventLive.Show, :edit
    end
  end

  scope "/", HajWeb do
    pipe_through [:browser, :require_authenticated_user, :require_spex_access]

    scope "/dashboard" do
      get "/", DashboardController, :index

      # Obsolete
      get "/my-data", DashboardController, :edit_user
      put "/my-data", DashboardController, :update_user

      # Merch stuff
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
