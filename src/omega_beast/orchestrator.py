from __future__ import annotations

import collections
import uuid
from typing import Any

from omega_beast.agent import AgentRegistry, AgentStatus, BaseAgent


class AgentOrchestrator:
    def __init__(self) -> None:
        self._agents: list[BaseAgent] = []
        self._queue: collections.deque[tuple[dict, str | None]] = collections.deque()
        self._results: dict[str, Any] = {}
        self._completed_count = 0
        self._registry = AgentRegistry()

    def add_agent(self, agent: BaseAgent) -> None:
        self._agents.append(agent)
        self._registry.register(agent)

    def remove_agent(self, agent_id: str) -> None:
        agent = self._registry.get(agent_id)
        if agent is not None:
            agent.stop()
            self._agents = [a for a in self._agents if a.id != agent_id]
            self._registry.unregister(agent_id)

    def submit_task(self, task: dict, agent_id: str | None = None) -> None:
        if not self._agents:
            raise ValueError("No agents available to handle tasks.")
        if "type" not in task:
            raise ValueError("Task must have a 'type' key.")
        self._queue.append((task, agent_id))

    def run_all(self) -> list[dict]:
        results: list[dict] = []
        rr_index = 0

        while self._queue:
            task, agent_id = self._queue.popleft()

            if agent_id is not None:
                agent = self._registry.get(agent_id)
            else:
                available = [
                    a for a in self._agents if a.status in (AgentStatus.IDLE, AgentStatus.COMPLETED)
                ]
                if not available:
                    available = self._agents
                agent = available[rr_index % len(available)]
                rr_index += 1

            if agent is None:
                result = {"error": f"Agent {agent_id!r} not found", "task": task}
            else:
                task_id = task.get("id", str(uuid.uuid4()))
                task["id"] = task_id
                try:
                    result = agent.start(task)
                    result.setdefault("task_id", task_id)
                except Exception as exc:
                    result = {"error": str(exc), "task_id": task_id, "status": "failed"}
                self._results[task_id] = result
                self._completed_count += 1

            results.append(result)

        return results

    def get_results(self) -> dict:
        return dict(self._results)

    def status_report(self) -> dict:
        return {
            "agents": [
                {
                    "id": a.id,
                    "name": a.name,
                    "status": a.status.value,
                    **a.metadata,
                }
                for a in self._agents
            ],
            "pending_tasks": len(self._queue),
            "completed_tasks": self._completed_count,
        }
