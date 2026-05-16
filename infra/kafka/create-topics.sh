#!/usr/bin/env bash
# Bootstrap the Kafka topics declared in data-model.md.
# Idempotent: safe to re-run.

set -euo pipefail

BOOTSTRAP="${KAFKA_BOOTSTRAP:-kafka:9092}"
REPLICATION="${KAFKA_REPLICATION_FACTOR:-1}"

topic() {
  local name="$1" partitions="$2" retention_ms="$3"
  echo "==> Ensuring topic ${name} (partitions=${partitions}, retention_ms=${retention_ms})"
  kafka-topics.sh --bootstrap-server "${BOOTSTRAP}" \
    --create --if-not-exists \
    --topic "${name}" \
    --partitions "${partitions}" \
    --replication-factor "${REPLICATION}" \
    --config "retention.ms=${retention_ms}" \
    --config "compression.type=lz4"
}

# Wait until the cluster is reachable.
for i in $(seq 1 30); do
  if kafka-topics.sh --bootstrap-server "${BOOTSTRAP}" --list >/dev/null 2>&1; then
    break
  fi
  echo "Waiting for Kafka at ${BOOTSTRAP}..."
  sleep 2
done

# Core streaming topics (retention in ms).
topic "market.ticks"        12 $((6 * 60 * 60 * 1000))       # 6h hot window
topic "candles.1m"           6 $((7 * 24 * 60 * 60 * 1000))  # 7d
topic "candles.5m"           6 $((30 * 24 * 60 * 60 * 1000)) # 30d
topic "candles.15m"          6 $((30 * 24 * 60 * 60 * 1000))
topic "candles.1h"           3 $((90 * 24 * 60 * 60 * 1000))
topic "candles.1d"           3 $((365 * 24 * 60 * 60 * 1000))
topic "analytics.triggers"   3 $((24 * 60 * 60 * 1000))
topic "alerts.fired"         3 $((30 * 24 * 60 * 60 * 1000))
topic "forecasts.updated"    3 $((30 * 24 * 60 * 60 * 1000))
topic "portfolio.snapshots"  3 $((365 * 24 * 60 * 60 * 1000))

echo "All KiteEdge topics ensured."
