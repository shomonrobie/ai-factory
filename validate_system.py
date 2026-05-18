#!/usr/bin/env python3
"""
System Validation Script - Validates complete system health
"""

import sys
import ast
from pathlib import Path
from typing import Dict, List

class SystemValidator:
    def __init__(self):
        self.results = {
            "structure": {},
            "syntax_errors": {},
            "overall": "unknown"
        }
    
    def validate_file_structure(self) -> Dict:
        """Validate file structure"""
        required = {
            "backend": ["app", "requirements.txt"],
            "frontend": ["app", "package.json"],
            "factory": ["agents", "engine", "orchestrator", "cli.py"],
            "database": ["migrations"],
            "docker": [],
            "tests": [],
            "scripts": []
        }
        
        for dir_name, sub_items in required.items():
            dir_path = Path(dir_name)
            exists = dir_path.exists() and dir_path.is_dir()
            
            children_status = {}
            if exists:
                for item in sub_items:
                    item_path = dir_path / item
                    children_status[item] = item_path.exists()
            
            self.results["structure"][dir_name] = {
                "exists": exists,
                "children": children_status
            }
        
        return self.results["structure"]
    
    def validate_syntax(self, filepath: Path) -> tuple:
        """Validate syntax of a single Python file"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Try to compile
            compile(content, str(filepath), 'exec')
            return True, None
        except SyntaxError as e:
            return False, f"Line {e.lineno}: {e.msg}"
        except Exception as e:
            return False, str(e)
    
    def validate_all_syntax(self) -> Dict:
        """Validate syntax of all Python files"""
        python_files = []
        
        # Find all Python files
        for pattern in ['*.py', '*/*.py', '*/*/*.py', '*/*/*/*.py']:
            python_files.extend(Path('.').glob(pattern))
        
        # Filter out virtual environment
        python_files = [f for f in python_files 
                       if 'venv' not in str(f) 
                       and '__pycache__' not in str(f)
                       and 'backup_before_fix' not in str(f)]
        
        errors = {}
        for py_file in python_files:
            valid, error = self.validate_syntax(py_file)
            if not valid:
                errors[str(py_file)] = error
        
        self.results["syntax_errors"] = errors
        return errors
    
    def generate_report(self) -> str:
        """Generate text report"""
        lines = []
        lines.append("=" * 60)
        lines.append("SYSTEM VALIDATION REPORT")
        lines.append("=" * 60)
        lines.append("")
        
        # File structure
        lines.append("DIRECTORY STRUCTURE:")
        lines.append("-" * 40)
        
        for dir_name, info in self.results["structure"].items():
            status = "EXISTS" if info["exists"] else "MISSING"
            lines.append(f"  [{status}] {dir_name}/")
            
            if info["exists"] and info["children"]:
                for child, exists in info["children"].items():
                    child_status = "OK" if exists else "MISSING"
                    lines.append(f"      [{child_status}] {child}")
        
        lines.append("")
        
        # Syntax errors
        lines.append("SYNTAX VALIDATION:")
        lines.append("-" * 40)
        
        if self.results["syntax_errors"]:
            lines.append(f"  Found {len(self.results['syntax_errors'])} files with errors:")
            for filepath, error in list(self.results["syntax_errors"].items())[:10]:
                filename = Path(filepath).name
                lines.append(f"    ERROR: {filename}")
                lines.append(f"      {error}")
        else:
            lines.append("  OK - All Python files have valid syntax!")
        
        lines.append("")
        
        # Summary
        lines.append("=" * 60)
        
        all_dirs_exist = all(v["exists"] for v in self.results["structure"].values())
        no_syntax_errors = len(self.results["syntax_errors"]) == 0
        
        if all_dirs_exist and no_syntax_errors:
            lines.append("STATUS: READY FOR PRODUCTION")
            lines.append("")
            lines.append("Next steps:")
            lines.append("  1. Run: docker-compose up -d")
            lines.append("  2. Access: http://localhost:8000/docs")
        elif all_dirs_exist:
            lines.append("STATUS: GENERATED - Has syntax errors")
            lines.append("")
            lines.append("Run the fix script:")
            lines.append("  python quick_fix.py")
        else:
            lines.append("STATUS: INCOMPLETE")
            lines.append("")
            lines.append("Run the setup script:")
            lines.append("  python run_factory_setup.py")
        
        lines.append("=" * 60)
        
        return '\n'.join(lines)
    
    def save_report(self, filename: str = "validation_report.txt"):
        """Save report to file"""
        report = self.generate_report()
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"\nReport saved to: {filename}")

def main():
    print("\n" + "=" * 60)
    print("AI SOFTWARE FACTORY - VALIDATOR")
    print("=" * 60 + "\n")
    
    validator = SystemValidator()
    
    print("Checking file structure...")
    validator.validate_file_structure()
    
    print("Checking Python syntax...")
    validator.validate_all_syntax()
    
    report = validator.generate_report()
    print(report)
    validator.save_report()
    
    # Return appropriate exit code
    if validator.results["syntax_errors"]:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nValidation interrupted")
        sys.exit(130)
    except Exception as e:
        print(f"\nError: {str(e)}")
        sys.exit(1)