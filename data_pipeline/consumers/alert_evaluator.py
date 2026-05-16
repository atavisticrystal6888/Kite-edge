"""
T161: Alert-rule evaluation consumer.

Consumes market ticks from Kafka and evaluates user-defined alert rules.
Fires matching alerts to the alerts.fired topic.
"""
from __future__ import annotations

import json
import logging
import os
from dataclasses import dataclass

logger = logging.getLogger(__name__)

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")


@dataclass
class AlertRule:
    rule_id: str
    symbol: str
    condition: str  # "price_above", "price_below", "change_pct"
    threshold: float
    user_id: str


def evaluate_tick(tick: dict, rules: list[AlertRule]) -> list[AlertRule]:
    """Evaluate a single tick against a set of alert rules, returning fired rules."""
    symbol = tick.get("symbol", "")
    price = tick.get("last_price", 0.0)
    fired: list[AlertRule] = []
    for rule in rules:
        if rule.symbol != symbol:
            continue
        if rule.condition == "price_above" and price > rule.threshold:
            fired.append(rule)
        elif rule.condition == "price_below" and price < rule.threshold:
            fired.append(rule)
    return fired


def run():
    """Start the alert evaluator consumer."""
    try:
        from confluent_kafka import Consumer, Producer
    except ImportError:
        logger.warning("confluent_kafka not installed; alert evaluator disabled.")
        return

    consumer_conf = {
        "bootstrap.servers": KAFKA_BOOTSTRAP,
        "group.id": "alert-evaluator",
        "auto.offset.reset": "latest",
    }
    producer_conf = {"bootstrap.servers": KAFKA_BOOTSTRAP}

    consumer = Consumer(consumer_conf)
    producer = Producer(producer_conf)
    consumer.subscribe(["market.ticks", "analytics.triggers"])

    logger.info("Alert evaluator started")

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
                fired = _evaluate(payload)
                for alert in fired:
                    producer.produce(
                        "alerts.fired",
                        json.dumps(alert).encode(),
                    )
                    producer.flush()
            except Exception:
                logger.exception("Failed to evaluate alert")
    finally:
        consumer.close()


def _evaluate(payload: dict) -> list[dict]:
    """Evaluate alert rules against the tick/trigger payload.

    In production: load rules from DB, compare conditions, return matches.
    """
    # Placeholder
    return []


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    run()
