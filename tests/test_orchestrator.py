from __future__ import annotations

import pytest

from omega_beast.agent import AgentRegistry, AgentStatus, BaseAgent
from omega_beast.orchestrator import AgentOrchestrator


class SimpleAgent(BaseAgent):
    def run(self, task: dict) -> dict:
        return {"agent": self.name, "type": task.get("type"), "status": "ok"}


@pytest.fixture(autouse=True)
def reset_registry():
    AgentRegistry().reset()
    yield
    AgentRegistry().reset()


def test_submit_task_no_agents():
    orch = AgentOrchestrator()
    with pytest.raises(ValueError, match="No agents"):
        orch.submit_task({"type": "ping"})


def test_submit_and_run():
    orch = AgentOrchestrator()
    orch.add_agent(SimpleAgent("worker"))
    orch.submit_task({"type": "ping"})
    results = orch.run_all()
    assert len(results) == 1
    assert results[0]["status"] == "ok"


def test_run_all_round_robin():
    orch = AgentOrchestrator()
    a1 = SimpleAgent("alpha")
    a2 = SimpleAgent("beta")
    orch.add_agent(a1)
    orch.add_agent(a2)
    orch.submit_task({"type": "task1"})
    orch.submit_task({"type": "task2"})
    results = orch.run_all()
    assert len(results) == 2
    agent_names = {r["agent"] for r in results}
    assert agent_names == {"alpha", "beta"}


def test_status_report():
    orch = AgentOrchestrator()
    orch.add_agent(SimpleAgent("sentinel"))
    orch.submit_task({"type": "probe"})
    orch.run_all()
    report = orch.status_report()
    assert "agents" in report
    assert "pending_tasks" in report
    assert "completed_tasks" in report
    assert report["completed_tasks"] == 1
    assert report["pending_tasks"] == 0
    assert len(report["agents"]) == 1
