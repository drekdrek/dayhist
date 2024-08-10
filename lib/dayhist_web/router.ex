defmodule DayhistWeb.Router do
  use DayhistWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DayhistWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DayhistWeb.Plugs.SetCounts
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/p", DayhistWeb, layout: {DayhistWeb.Layouts, :playlist} do
    pipe_through :browser

    live "/:playlist", PlaylistLive, :playlist
  end

  scope "/", DayhistWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", PageLive, :home
  end

  scope "/faq", DayhistWeb do
    pipe_through :browser

    get "/autofetch", PageController, :autofetch
  end

  pipeline :auth_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DayhistWeb.Plugs.RedirectPlug
  end

  scope "/auth", DayhistWeb do
    pipe_through :auth_browser

    # get "/login", AuthController, :new
    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    post "/logout", AuthController, :delete
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", DayhistWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dayhist, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DayhistWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
