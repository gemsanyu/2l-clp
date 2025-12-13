
import json
from pathlib import Path

from problem.problem import Problem, from_json


def run(problem_json_path: Path):
    problem: Problem
    with open(problem_json_path, "r") as f:
        json_data = json.load(f)
        problem = from_json(json_data)

if __name__ == "__main__":
    instance_filename = "instance_107.json"
    instance_json_path = Path("instances")/instance_filename
    run(instance_json_path)
