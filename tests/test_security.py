from __future__ import annotations

import pytest

from omega_beast.security import ApiKeyAuth, RateLimiter, Sanitizer


def test_rate_limiter_allows_under_limit():
    rl = RateLimiter(max_calls=3, period=60.0)
    assert rl.is_allowed("user1") is True
    assert rl.is_allowed("user1") is True
    assert rl.is_allowed("user1") is True


def test_rate_limiter_blocks_over_limit():
    rl = RateLimiter(max_calls=2, period=60.0)
    assert rl.is_allowed("user2") is True
    assert rl.is_allowed("user2") is True
    assert rl.is_allowed("user2") is False


def test_rate_limiter_reset():
    rl = RateLimiter(max_calls=1, period=60.0)
    assert rl.is_allowed("user3") is True
    assert rl.is_allowed("user3") is False
    rl.reset("user3")
    assert rl.is_allowed("user3") is True


def test_api_key_auth_generate_and_validate():
    auth = ApiKeyAuth()
    key = auth.generate_key()
    assert len(key) == 32
    assert auth.validate(key) is True


def test_api_key_auth_invalid_key():
    auth = ApiKeyAuth()
    assert auth.validate("not-a-valid-key-xxxxxxxxx") is False


def test_api_key_short_key_raises():
    auth = ApiKeyAuth()
    with pytest.raises(ValueError, match="at least 16"):
        auth.add_key("short")


def test_sanitizer_string():
    assert Sanitizer.sanitize_string("  hello  ") == "hello"
    assert Sanitizer.sanitize_string("a" * 2000, max_length=10) == "a" * 10


def test_sanitizer_task_valid():
    task = {"type": "greet", "message": "  hello  "}
    cleaned = Sanitizer.sanitize_task(task)
    assert cleaned["type"] == "greet"
    assert cleaned["message"] == "hello"


def test_sanitizer_task_missing_type():
    with pytest.raises(ValueError, match="'type'"):
        Sanitizer.sanitize_task({"data": "x"})


def test_sanitizer_task_not_dict():
    with pytest.raises(TypeError, match="dict"):
        Sanitizer.sanitize_task("not a dict")  # type: ignore[arg-type]
