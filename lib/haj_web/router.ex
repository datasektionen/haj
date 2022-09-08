defmodule HajWeb.Router do
  use HajWeb, :router

  import HajWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HajWeb.LayoutView, :root}
    plug :put_layout, {HajWeb.LayoutView, :haj}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HajWeb do
    pipe_through :browser

    # get "/", PageController, :index
    # get "/groups", PageController, :groups
    # get "/groups/:name", PageController, :group
    # get "/spexet", PageController, :spex
    # get "/previous", PageController, :previous
    # get "/about", PageController, :about


    get "/login", SessionController, :login
    get "/login/callback", SessionController, :callback
    get "/logout", SessionController, :logout

    get "/", LoginController, :login
    get "/unauthorized", LoginController, :unauthorized
  end

  scope "/", HajWeb do
    pipe_through [:browser, :require_authenticated_user, :require_spex_access]

    get "/dashboard", DashboardController, :index
    get "/dashboard/my-data", DashboardController, :edit_user
    put "/dashboard/my-data", DashboardController, :update_user

    get "/user/:username", UserController, :index
    get "/user/:username/groups", UserController, :groups

    get "/members", MembersController, :index

    get "/settings", SettingsController, :index
    get "/settings/groups", SettingsController, :groups
    get "/settings/groups/new", SettingsController, :new_group
    post "/settings/groups", SettingsController, :create_group
    get "/settings/groups/:id", SettingsController, :edit_group
    put  "/settings/groups/:id", SettingsController, :update_group
    delete "/settings/groups/:id", SettingsController, :delete_group


    get "/settings/show/:show_id/groups", SettingsController, :show_groups
    get "/settings/show-group/:id", SettingsController, :edit_show_group
    delete "/settings/show-group/:id", SettingsController, :delete_show_group
    post "/settings/show/:show_id/groups", SettingsController, :add_show_group

    get "/settings/shows", SettingsController, :shows
    get "/settings/show/new", SettingsController, :new_show
    post "/settings/show", SettingsController, :create_show
    get "/settings/show/:id", SettingsController, :edit_show
    put "/settings/show/:id", SettingsController, :update_show


    get "/show-groups", GroupController, :index
    get "/show-groups/edit/:show_group_id", GroupController, :edit
    get "/show-groups/:show_group_id", GroupController, :group
    get "/show-groups/:show_group_id/vcard", GroupController, :vcard
    get "/show-groups/:show_group_id/applications", GroupController, :applications


    get "/applications", ApplicationController, :index
    get "/applications/export", ApplicationController, :export
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
