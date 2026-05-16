"""
T072, T190: Indicator updater consumer.

Listens on Kafka candle-close topics and triggers indicator recomputation.
Supports timeframe aggregation and pre-computation scheduling.
"""
from __future__ import annotations

import json
import logging
import os

logger = logging.getLogger(__name__)

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
CANDLE_TOPICS = ["candles.1m", "candles.5m", "candles.15m", "candles.1h", "candles.1d"]


def run():
    """Start the indicator updater consumer."""
    try:
        from confluent_kafka import Consumer
    except ImportError:
        logger.warning("confluent_kafka not installed; indicator updater disabled.")
        return

    conf = {
        "bootstrap.servers": KAFKA_BOOTSTRAP,
        "group.id": "indicator-updater",
        "auto.offset.reset": "latest",
    }
    consumer = Consumer(conf)
    consumer.subscribe(CANDLE_TOPICS)

    logger.info("Indicator updater started, subscribed to %s", CANDLE_TOPICS)

    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                logger.error("Consumer error: %s", msg.error())
                continue

            try:
                payload = json.loads(msg.value())
                _process_candle(payload, msg.topic())
            except Exception:
                logger.exception("Failed to process candle message")
    finally:
        consumer.close()


def _process_candle(payload: dict, topic: str):
    """Process a candle close event and trigger indicator recomputation."""
    symbol = payload.get("symbol", "unknown")
    timeframe = topic.split(".")[-1] if "." in topic else "1d"
    logger.info("Recomputing indicators for %s on %s timeframe", symbol, timeframe)
    # In production: load OHLCV, compute indicators, store results
    # For now this is a placeholder that logs the event


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    run()
