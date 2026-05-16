defmodule KiteEdgeWeb.Router do
  use KiteEdgeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug KiteEdgeWeb.Plugs.SecurityHeaders
  end

  pipeline :api_authed do
    plug :accepts, ["json"]
    plug KiteEdgeWeb.Plugs.SecurityHeaders
    plug KiteEdgeWeb.Plugs.RateLimiter, limit: 60, window_ms: 60_000
    plug KiteEdgeWeb.Plugs.VerifyOrigin
    plug KiteEdgeWeb.Plugs.RequireSession
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  # ---- Public ----

  scope "/auth/kite", KiteEdgeWeb do
    pipe_through :browser
    get "/login", AuthController, :login
    get "/callback", AuthController, :callback
    delete "/logout", AuthController, :logout
  end

  # Health & metrics (no auth)
  scope "/", KiteEdgeWeb do
    pipe_through :api
    get "/health", HealthMetricsController, :health
    get "/metrics", HealthMetricsController, :metrics
  end

  # ---- Authenticated API ----

  scope "/api/v1", KiteEdgeWeb do
    pipe_through :api_authed

    # Portfolio (Phase 3)
    scope "/portfolio", Portfolio, as: :portfolio do
      get "/holdings", HoldingsController, :index
      get "/summary", SummaryController, :show
    end

    # Instruments (Remediation C1)
    get "/instruments/search", InstrumentsController, :search
    get "/instruments/:symbol/quote", InstrumentsController, :quote
    get "/instruments/:symbol/ohlcv", InstrumentsController, :ohlcv

    # Technical Analysis (Phase 4)
    scope "/analytics/technical", Analytics, as: :analytics_technical do
      post "/:symbol", TechnicalController, :analyze
      get "/:symbol/summary", TechnicalController, :summary
    end

    # Risk Analytics (Phase 5)
    scope "/analytics/risk", Analytics, as: :analytics_risk do
      post "/portfolio", RiskController, :portfolio
      post "/var", RiskController, :var
      post "/montecarlo", RiskController, :montecarlo
      post "/stress-test", RiskController, :stress_test
      post "/correlation", RiskController, :correlation
    end

    # Forecast (Phase 6)
    scope "/analytics/forecast", Analytics, as: :analytics_forecast do
      post "/portfolio", ForecastController, :portfolio
      post "/:symbol", ForecastController, :instrument
    end

    # Trade Analytics (Phase 7)
    scope "/analytics/trades", Analytics, as: :analytics_trades do
      get "/performance", TradesController, :performance
    end

    # Signals & Suggestions (Phase 8)
    scope "/analytics", Analytics, as: :analytics_suggestions do
      get "/signals", SuggestionsController, :signals
      post "/rebalance", SuggestionsController, :rebalance
    end

    # Watchlists (Remediation C2)
    resources "/watchlists", WatchlistsController, only: [:index, :create, :update, :delete]

    # Settings (Remediation I1)
    scope "/settings", Settings, as: :settings do
      get "/indicator-profile", IndicatorProfileController, :show
      put "/indicator-profile", IndicatorProfileController, :update
      delete "/indicator-profile", IndicatorProfileController, :reset
    end

    # Reports (Phase 9)
    scope "/reports", Reports, as: :reports do
      post "/tearsheet", ReportController, :tearsheet
      post "/export", ReportController, :export
      get "/odata/holdings", ODataController, :index
      get "/odata/$metadata", ODataController, :metadata
      get "/powerbi/push", PowerBIController, :push
    end
  end
end
