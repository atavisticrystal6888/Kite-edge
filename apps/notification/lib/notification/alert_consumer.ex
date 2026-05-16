defmodule Notification.AlertConsumer do
  @moduledoc "T162: Kafka alert-delivery consumer."
  use Broadway

  require Logger

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayKafka.Producer, [
          hosts: [localhost: 9092],
          group_id: "alert-consumer",
          topics: ["alerts.fired"]
        ]},
        concurrency: 1
      ],
      processors: [default: [concurrency: 2]]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    case Jason.decode(message.data) do
      {:ok, alert} ->
        deliver_alert(alert)
        message

      {:error, _} ->
        Logger.warning("Failed to decode alert message")
        Broadway.Message.failed(message, "decode_error")
    end
  end

  defp deliver_alert(alert) do
    user_id = alert["user_id"]
    Logger.info("Delivering alert to user #{user_id}: #{alert["headline"]}")

    # In-app: broadcast via Phoenix PubSub
    Phoenix.PubSub.broadcast(KiteEdge.PubSub, "alerts:#{user_id}", {:alert, alert})

    # Email: check preferences and send if enabled
    # Notification.EmailAdapter.maybe_send(user_id, alert)
  end
end
