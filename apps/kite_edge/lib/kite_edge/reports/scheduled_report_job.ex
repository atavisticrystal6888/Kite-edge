defmodule KiteEdge.Reports.ScheduledReportJob do
  @moduledoc "T178: Scheduled report job using Oban."

  use Oban.Worker, queue: :reports, max_attempts: 3

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    user_id = args["user_id"]
    report_type = args["report_type"] || "tearsheet"
    period_start = args["period_start"]
    period_end = args["period_end"]

    Logger.info("Generating scheduled #{report_type} report for user #{user_id}")

    # In production:
    # 1. Fetch portfolio returns from DB
    # 2. Call analytics engine tearsheet/export endpoint
    # 3. Store the result and notify user

    :ok
  end
end
