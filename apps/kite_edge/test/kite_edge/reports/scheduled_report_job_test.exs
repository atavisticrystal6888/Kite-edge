defmodule KiteEdge.Reports.ScheduledReportJobTest do
  use ExUnit.Case, async: true

  alias KiteEdge.Reports.ScheduledReportJob

  @moduletag :phase9

  describe "module structure" do
    test "scheduled_report_job module exists" do
      assert Code.ensure_loaded?(ScheduledReportJob)
    end

    test "implements Oban.Worker perform/1" do
      assert function_exported?(ScheduledReportJob, :perform, 1)
    end
  end
end
