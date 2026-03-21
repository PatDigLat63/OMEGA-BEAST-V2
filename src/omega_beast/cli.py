from __future__ import annotations

import argparse
import json

from omega_beast.agent import BaseAgent
from omega_beast.orchestrator import AgentOrchestrator


class ExampleAgent(BaseAgent):
    def run(self, task: dict) -> dict:
        return {
            "agent": self.name,
            "task_type": task.get("type"),
            "result": "completed",
        }


def _cmd_version(_args: argparse.Namespace) -> None:
    print("OMEGA-BEAST v2.0.0 🔱")


def _cmd_status(_args: argparse.Namespace) -> None:
    orchestrator = AgentOrchestrator()
    report = orchestrator.status_report()
    print(json.dumps(report, indent=2))


def _cmd_run(args: argparse.Namespace) -> None:
    orchestrator = AgentOrchestrator()
    for i in range(args.agent_count):
        orchestrator.add_agent(ExampleAgent(name=f"agent-{i + 1}"))
    orchestrator.submit_task({"type": args.task_type})
    results = orchestrator.run_all()
    print(json.dumps(results, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="omega-beast",
        description="OMEGA-BEAST v2 — autonomous agent orchestration framework",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("version", help="Print version information")

    subparsers.add_parser("status", help="Print orchestrator status report")

    run_parser = subparsers.add_parser("run", help="Run a task with agents")
    run_parser.add_argument("--task-type", required=True, help="Task type to submit")
    run_parser.add_argument(
        "--agent-count", type=int, default=1, help="Number of agents to create (default: 1)"
    )

    args = parser.parse_args()
    dispatch = {
        "version": _cmd_version,
        "status": _cmd_status,
        "run": _cmd_run,
    }
    dispatch[args.command](args)


if __name__ == "__main__":
    main()
