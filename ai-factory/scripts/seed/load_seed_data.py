# scripts/seed/load_seed_data.py
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

def load_json_file(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)

def load_demo_users():
    users = load_json_file("scripts/seed/demo_users.json")
    print(f"Loaded {len(users)} demo users")
    return users

def load_demo_projects():
    projects = load_json_file("scripts/seed/demo_projects.json")
    print(f"Loaded {len(projects)} demo projects")
    return projects

def load_demo_batches():
    batches = load_json_file("scripts/seed/demo_batches.json")
    print(f"Loaded {len(batches)} demo batches")
    return batches

def load_testimonials():
    testimonials = load_json_file("data/seed/testimonials.json")
    print(f"Loaded {len(testimonials)} testimonials")
    return testimonials

def load_case_studies():
    case_studies = load_json_file("data/seed/case_studies.json")
    print(f"Loaded {len(case_studies)} case studies")
    return case_studies

if __name__ == "__main__":
    print("Loading seed data...")
    load_demo_users()
    load_demo_projects()
    load_demo_batches()
    load_testimonials()
    load_case_studies()
    print("Seed data loaded successfully!")
