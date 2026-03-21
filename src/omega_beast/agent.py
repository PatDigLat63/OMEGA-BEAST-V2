from __future__ import annotations

import abc
import time
import uuid
from enum import Enum
from typing import Any


class AgentStatus(Enum):
    IDLE = "idle"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    STOPPED = "stopped"


class BaseAgent(abc.ABC):
    def __init__(self, name: str, agent_id: str | None = None) -> None:
        self._name = name
        self._id = agent_id if agent_id is not None else str(uuid.uuid4())
        self._status = AgentStatus.IDLE
        self._metadata: dict[str, Any] = {}

    @property
    def name(self) -> str:
        return self._name

    @property
    def id(self) -> str:
        return self._id

    @property
    def status(self) -> AgentStatus:
        return self._status

    @property
    def metadata(self) -> dict[str, Any]:
        return dict(self._metadata)

    @abc.abstractmethod
    def run(self, task: dict) -> dict:
        """Execute the given task and return a result dict."""

    def start(self, task: dict) -> dict:
        self._status = AgentStatus.RUNNING
        start_time = time.time()
        self._metadata["start_time"] = start_time
        try:
            result = self.run(task)
            self._status = AgentStatus.COMPLETED
        except Exception as exc:
            self._status = AgentStatus.FAILED
            end_time = time.time()
            self._metadata["end_time"] = end_time
            self._metadata["duration"] = end_time - start_time
            raise exc
        end_time = time.time()
        self._metadata["end_time"] = end_time
        self._metadata["duration"] = end_time - start_time
        return result

    def stop(self) -> None:
        self._status = AgentStatus.STOPPED


class AgentRegistry:
    _instance: AgentRegistry | None = None
    _agents: dict[str, BaseAgent]

    def __new__(cls) -> AgentRegistry:
        if cls._instance is None:
            instance = super().__new__(cls)
            instance._agents = {}
            cls._instance = instance
        return cls._instance

    def register(self, agent: BaseAgent) -> None:
        self._agents[agent.id] = agent

    def unregister(self, agent_id: str) -> None:
        self._agents.pop(agent_id, None)

    def get(self, agent_id: str) -> BaseAgent | None:
        return self._agents.get(agent_id)

    def list_agents(self) -> list[BaseAgent]:
        return list(self._agents.values())

    def reset(self) -> None:
        self._agents.clear()
