from __future__ import annotations

import secrets
import time
from collections import deque


class RateLimiter:
    def __init__(self, max_calls: int, period: float) -> None:
        self._max_calls = max_calls
        self._period = period
        self._history: dict[str, deque[float]] = {}

    def is_allowed(self, key: str) -> bool:
        now = time.monotonic()
        window_start = now - self._period
        if key not in self._history:
            self._history[key] = deque()
        history = self._history[key]
        # Drop timestamps outside the sliding window
        while history and history[0] <= window_start:
            history.popleft()
        if len(history) < self._max_calls:
            history.append(now)
            return True
        return False

    def reset(self, key: str) -> None:
        self._history.pop(key, None)


class ApiKeyAuth:
    def __init__(self, valid_keys: set[str] | None = None) -> None:
        self._valid_keys: set[str] = set(valid_keys) if valid_keys else set()

    def add_key(self, key: str) -> None:
        if not isinstance(key, str) or len(key) < 16:
            raise ValueError("API key must be a string of at least 16 characters.")
        self._valid_keys.add(key)

    def remove_key(self, key: str) -> None:
        self._valid_keys.discard(key)

    def validate(self, key: str) -> bool:
        return isinstance(key, str) and key in self._valid_keys

    def generate_key(self) -> str:
        key = secrets.token_hex(16)  # 32 hex chars
        self._valid_keys.add(key)
        return key


class Sanitizer:
    @staticmethod
    def sanitize_string(value: str, max_length: int = 1024) -> str:
        return value.strip()[:max_length]

    @staticmethod
    def sanitize_task(task: dict) -> dict:
        if not isinstance(task, dict):
            raise TypeError("Task must be a dict.")
        if "type" not in task:
            raise ValueError("Task must contain a 'type' key.")
        if not isinstance(task["type"], str) or not task["type"].strip():
            raise ValueError("Task 'type' must be a non-empty string.")
        cleaned: dict = {}
        for k, v in task.items():
            cleaned[k] = Sanitizer.sanitize_string(v) if isinstance(v, str) else v
        return cleaned
