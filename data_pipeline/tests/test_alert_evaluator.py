"""T154: Integration tests for alert-rule evaluation and firing."""
import pytest
from data_pipeline.consumers.alert_evaluator import evaluate_tick, AlertRule


@pytest.fixture
def sample_rules():
    return [
        AlertRule(
            rule_id="r1",
            symbol="RELIANCE",
            condition="price_above",
            threshold=2500.0,
            user_id="user_1",
        ),
        AlertRule(
            rule_id="r2",
            symbol="INFY",
            condition="price_below",
            threshold=1400.0,
            user_id="user_2",
        ),
    ]


def test_evaluate_tick_triggers_above(sample_rules):
    tick = {"symbol": "RELIANCE", "last_price": 2550.0}
    fired = evaluate_tick(tick, sample_rules)
    assert len(fired) == 1
    assert fired[0].rule_id == "r1"


def test_evaluate_tick_no_trigger(sample_rules):
    tick = {"symbol": "RELIANCE", "last_price": 2400.0}
    fired = evaluate_tick(tick, sample_rules)
    assert len(fired) == 0


def test_evaluate_tick_triggers_below(sample_rules):
    tick = {"symbol": "INFY", "last_price": 1350.0}
    fired = evaluate_tick(tick, sample_rules)
    assert len(fired) == 1
    assert fired[0].rule_id == "r2"


def test_evaluate_tick_unknown_symbol(sample_rules):
    tick = {"symbol": "TCS", "last_price": 3500.0}
    fired = evaluate_tick(tick, sample_rules)
    assert len(fired) == 0
