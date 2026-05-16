defmodule Notification.EmailAdapter do
  @moduledoc "T163c: Swoosh-based email alert adapter with token-safe templates."

  import Swoosh.Email
  alias KiteEdge.Logging.Redactor

  @from_address {"KiteEdge Alerts", "alerts@kiteedge.local"}

  def send_alert(to_email, alert) when is_binary(to_email) do
    safe_alert = Redactor.redact(alert)

    email =
      new()
      |> to(to_email)
      |> from(@from_address)
      |> subject("[KiteEdge Alert] #{safe_alert["headline"] || safe_alert[:headline] || "Alert"}")
      |> text_body(build_text(safe_alert))

    case Notification.Mailer.deliver(email) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_text(alert) do
    """
    KiteEdge Alert
    ===============

    #{alert["headline"] || alert[:headline] || ""}

    #{alert["body"] || alert[:body] || ""}

    Symbol: #{alert["symbol"] || alert[:symbol] || "N/A"}
    Time: #{alert["fired_at"] || alert[:fired_at] || ""}

    ---
    Disclaimer: KiteEdge is a personal research tool. It does not provide
    investment advice, does not execute trades, and does not guarantee outcomes.
    """
  end
end
