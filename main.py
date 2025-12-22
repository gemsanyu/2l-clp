
import json
from pathlib import Path
import random
import string
import subprocess

from problem.problem import Problem, from_json


def random_string(length=10):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def prepare_runfile(dat_relative_path: str)->Path:
    tmp_dir = Path(".tmp")
    tmp_dir.mkdir(parents=True, exist_ok=True)
    run_template_path = Path("run_templates")/"cartonization.run_template"
    run_template = run_template_path.read_text()
    run_text = run_template.replace("$DATA_FILE$", dat_relative_path)
    run_filename = random_string(5)
    run_filepath = tmp_dir/f"{run_filename}.run"
    run_filepath.write_text(run_text)
    return run_filepath

def solve_cartonization(dat_relative_path: str):
    run_filepath = prepare_runfile(dat_relative_path)
    print(str(run_filepath))
    cmd_args = [
        "ampl",
        str(run_filepath)
    ]
    try:
        subprocess.run(cmd_args)
    except subprocess.CalledProcessError as e:
        print(f"⚠️ failed with exit code {e.returncode}")    
    exit()
    


def run(problem_json_path: Path):
    problem: Problem
    with open(problem_json_path, "r") as f:
        json_data = json.load(f)
        problem = from_json(json_data)
    instance_name = problem_json_path.stem
    cust_dats_write_dir = problem_json_path.parent/instance_name
    cust_dats_write_dir.mkdir(parents=True, exist_ok=True)
    problem.generate_per_customer_dats(cust_dats_write_dir)
    dat_path_list = cust_dats_write_dir.glob("*")
    dat_relative_path_list = [str(dat_path) for dat_path in dat_path_list]
    for dat_relative_path in dat_relative_path_list:
        solve_cartonization(dat_relative_path)
        exit()
    
if __name__ == "__main__":
    instance_filename = "instance_107.json"
    instance_json_path = Path("instances")/instance_filename
    run(instance_json_path)
