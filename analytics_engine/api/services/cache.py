"""
T191: Redis caching for hot analytics queries.
"""
from __future__ import annotations

import json
import hashlib
from functools import wraps
from typing import Any, Callable

import redis

_client: redis.Redis | None = None


def get_redis() -> redis.Redis:
    global _client
    if _client is None:
        import os
        _client = redis.Redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379/1"))
    return _client


def cache_key(prefix: str, params: dict) -> str:
    raw = json.dumps(params, sort_keys=True, default=str)
    h = hashlib.sha256(raw.encode()).hexdigest()[:16]
    return f"analytics_cache:{prefix}:{h}"


def cached(prefix: str, ttl: int = 300):
    """Decorator to cache function results in Redis."""
    def decorator(fn: Callable) -> Callable:
        @wraps(fn)
        def wrapper(*args, **kwargs):
            r = get_redis()
            key = cache_key(prefix, {"args": str(args), **kwargs})
            hit = r.get(key)
            if hit:
                return json.loads(hit)
            result = fn(*args, **kwargs)
            try:
                r.setex(key, ttl, json.dumps(result, default=str))
            except (TypeError, redis.RedisError):
                pass
            return result
        return wrapper
    return decorator
