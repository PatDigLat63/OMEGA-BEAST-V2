# OMEGA-BEAST-V2 🔱

OMEGA-BEAST-V2 – The untamed core. High‑performance agents, autonomous coordination, and ruthless security. Forged in Brotherhood resolve. Unleash the beast.

## Overview

OMEGA-BEAST is a Python-based autonomous agent orchestration framework built on the standard library. It provides:

- **Agent abstraction** — define custom agents by subclassing `BaseAgent`
- **Orchestration** — submit tasks, route them to agents with round-robin scheduling
- **Security** — rate limiting, API key auth, and input sanitization
- **CLI** — `omega-beast` command for quick interaction

## Installation

```bash
pip install -e ".[dev]"   # development (includes pytest)
pip install -e .           # production
```

Requires **Python 3.10+**. No third-party runtime dependencies.

## Usage

### CLI

```bash
omega-beast version                          # OMEGA-BEAST v2.0.0 🔱
omega-beast status                           # JSON status report
omega-beast run --task-type ping             # run one task with one agent
omega-beast run --task-type scan --agent-count 3
```

### Programmatic API

```python
from omega_beast import AgentOrchestrator, BaseAgent

class MyAgent(BaseAgent):
    def run(self, task: dict) -> dict:
        return {"result": f"processed {task['type']}"}

orch = AgentOrchestrator()
orch.add_agent(MyAgent("worker-1"))
orch.submit_task({"type": "crawl"})
results = orch.run_all()
print(results)
```

## Architecture

```
src/omega_beast/
  agent.py        # BaseAgent (abstract), AgentStatus (enum), AgentRegistry (singleton)
  orchestrator.py # AgentOrchestrator — task queue, round-robin dispatch, result store
  security.py     # RateLimiter, ApiKeyAuth, Sanitizer
  cli.py          # argparse CLI entry-point + ExampleAgent
```

### AgentRegistry

A singleton that tracks all registered agents by UUID. Agents are automatically registered when added to an orchestrator via `add_agent()`.

### Task lifecycle

1. `submit_task({"type": "..."})` — enqueued
2. `run_all()` — dequeued, routed to an agent, `agent.start(task)` called
3. `agent.start()` sets `RUNNING`, calls `run()`, sets `COMPLETED`/`FAILED`, records timing

## Security

| Feature | Class | Description |
|---|---|---|
| Rate limiting | `RateLimiter` | Sliding-window call limiter per key |
| API key auth | `ApiKeyAuth` | Validates keys ≥16 chars; generates 32-char hex keys via `secrets` |
| Input sanitization | `Sanitizer` | Strips/truncates strings; validates task dicts |

```python
from omega_beast.security import RateLimiter, ApiKeyAuth, Sanitizer

# Rate limiting
rl = RateLimiter(max_calls=10, period=60.0)
rl.is_allowed("user-id")          # True / False

# API key auth
auth = ApiKeyAuth()
key = auth.generate_key()          # secure 32-char hex key
auth.validate(key)                 # True

# Sanitization
clean = Sanitizer.sanitize_task({"type": "ping", "data": "  hello  "})
```

## Running Tests

```bash
PYTHONPATH=src python -m pytest tests/ -v
```

21 tests covering agents, orchestrator, and security modules.
