from __future__ import annotations

import pytest

from omega_beast.agent import AgentRegistry, AgentStatus, BaseAgent


class ConcreteAgent(BaseAgent):
    def __init__(self, name: str, agent_id: str | None = None, *, fail: bool = False) -> None:
        super().__init__(name, agent_id)
        self._fail = fail

    def run(self, task: dict) -> dict:
        if self._fail:
            raise RuntimeError("intentional failure")
        return {"done": True, "task": task}


@pytest.fixture(autouse=True)
def reset_registry():
    AgentRegistry().reset()
    yield
    AgentRegistry().reset()


def test_agent_status_idle():
    agent = ConcreteAgent("alice")
    assert agent.status == AgentStatus.IDLE


def test_agent_start_success():
    agent = ConcreteAgent("bob")
    result = agent.start({"type": "greet"})
    assert agent.status == AgentStatus.COMPLETED
    assert result["done"] is True
    assert "duration" in agent.metadata


def test_agent_start_failure():
    agent = ConcreteAgent("charlie", fail=True)
    with pytest.raises(RuntimeError):
        agent.start({"type": "greet"})
    assert agent.status == AgentStatus.FAILED


def test_agent_stop():
    agent = ConcreteAgent("diana")
    agent.stop()
    assert agent.status == AgentStatus.STOPPED


def test_agent_registry_register_get():
    agent = ConcreteAgent("eve")
    registry = AgentRegistry()
    registry.register(agent)
    assert registry.get(agent.id) is agent


def test_agent_registry_list():
    registry = AgentRegistry()
    a1 = ConcreteAgent("f1")
    a2 = ConcreteAgent("f2")
    registry.register(a1)
    registry.register(a2)
    agents = registry.list_agents()
    assert len(agents) == 2
    ids = {a.id for a in agents}
    assert a1.id in ids and a2.id in ids


def test_agent_registry_unregister():
    registry = AgentRegistry()
    agent = ConcreteAgent("grace")
    registry.register(agent)
    registry.unregister(agent.id)
    assert registry.get(agent.id) is None
