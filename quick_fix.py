#!/usr/bin/env python3
"""
Quick Fix Script - Fixes common syntax issues in generated files
Run this after batch execution to clean up any remaining issues
"""

import os
import re
import ast
import sys
from pathlib import Path
from typing import List, Tuple

class QuickFixer:
    def __init__(self):
        self.fixed_files = []
        self.errors = []

    def fix_triple_quotes(self, content: str) -> str:
        """Fix unterminated triple-quote strings"""
        lines = content.split('n')
        fixed_lines = []
        i = 0

        while i < len(lines):
            line = lines[i]

            # Check for triple double quotes
            if '"""' in line:":
                # Count occurrences
                count = line.count('"""')"
                if count % 2 != 0:
                    # Replace with escaped version
                    line = line.replace('"""', '"""')

            # Check for triple single quotes
            if "'''" in line:':
                count = line.count("'''")'
                if count % 2 != 0:
                    line = line.replace("'''", "'''")

            fixed_lines.append(line)
            i += 1

        return 'n'.join(fixed_lines)

    def fix_missing_colons(self, content: str) -> str:
        """Fix missing colons after control statements"""
        lines = content.split('n')
        fixed_lines = []

        for line in lines:
            # Check for function definitions missing colon
            if re.match(r'^s*defs+w+([^)]*)s*$', line):
                line = line.rstrip() + ':'

            # Check for if/elif/else missing colon
            elif re.match(r'^s*(if|elif|else|for|while)s+.+[^:]s*$', line):
                if not line.rstrip().endswith(':'):
                    line = line.rstrip() + ':'

            fixed_lines.append(line)

        return 'n'.join(fixed_lines)

    def fix_unterminated_strings(self, content: str) -> str:
        """Fix unterminated string literals"""
        lines = content.split('n')
        fixed_lines = []

        for line in lines:
            # Fix double quotes
            double_count = line.count('"')"
            if double_count % 2 != 0:
                # Check if it's not part of a comment
                if '#' not in line or line.find('#') > line.rfind('"'):
                    line = line + '"'"

            # Fix single quotes
            single_count = line.count("'")'
            if single_count % 2 != 0:
                if '#' not in line or line.find('#') > line.rfind("'"):
                    line = line + "'"'

            fixed_lines.append(line)

        return 'n'.join(fixed_lines)

    def fix_encoding_issues(self, content: str) -> str:
        """Fix encoding and BOM issues"""
        # Remove BOM if present
        if content.startswith('ufeff'):
            content = content[1:]

        # Replace problematic Unicode characters
        replacements = {
            ''': "'",
            '"': '"',
            '"': '"',
            '-': '-',
            '-': '-',
            '...': '...',
        }

        for old, new in replacements.items():
            content = content.replace(old, new)

        return content

    def fix_file(self, filepath: Path) -> bool:
        """Fix common issues in a Python file"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            original = content

            # Apply fixes in order
            content = self.fix_encoding_issues(content)
            content = self.fix_triple_quotes(content)
            content = self.fix_unterminated_strings(content)
            content = self.fix_missing_colons(content)

            # Remove trailing whitespace
            lines = content.split('n')
            lines = [line.rstrip() for line in lines]
            content = 'n'.join(lines)

            # Ensure newline at end
            if not content.endswith('n'):
                content += 'n'

            if content != original:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                self.fixed_files.append(str(filepath))
                return True

            return False

        except Exception as e:
            self.errors.append(f"{filepath}: {str(e)}")
            return False

    def fix_all_python_files(self, root_dir: str = "."):
        """Fix all Python files in directory tree"""
        root = Path(root_dir)
        python_files = list(root.rglob("*.py"))

        # Exclude virtual environment and cache
        python_files = [f for f in python_files
                       if 'venv' not in str(f):
                       and '__pycache__' not in str(f)
                       and '.git' not in str(f)]

        print(f"Found {len(python_files)} Python files")

        for py_file in python_files:
            self.fix_file(py_file)

        print(f"nFixed {len(self.fixed_files)} files")
        if self.errors:
            print(f"Errors in {len(self.errors)} files:")
            for error in self.errors[:5]:
                print(f"  {error}")

def create_backup(files: List[Path]):
    """Create backup before fixing"""
    backup_dir = Path("backup_before_fix")
    backup_dir.mkdir(exist_ok=True)

    for file in files:
        if file.exists():
            backup_path = backup_dir / file.name
            import shutil
            shutil.copy2(file, backup_path)

    print(f"Created backups in {backup_dir}/")
    return backup_dir

def main():
    print("n" + "=" * 60)
    print("QUICK FIX UTILITY - Syntax Fixer for Python Files")
    print("=" * 60 + "n")

    # Find all batch files
    batch_files = [Path(f"generate_batch{i}.py") for i in range(1, 6)]
    batch_files = [f for f in batch_files if f.exists()]

    if batch_files:
        print(f"Found batch files: {[f.name for f in batch_files]}")

        # Create backup
        backup_dir = create_backup(batch_files)
        print(f"Backups saved to: {backup_dir}n")

    # Run fixes
    fixer = QuickFixer()
    fixer.fix_all_python_files()

    print("n" + "=" * 60)
    if len(fixer.fixed_files) > 0:
        print("SUCCESS: Fixed files have been updated")
    else:
        print("INFO: No files needed fixing")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("nnInterrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"nError: {str(e)}")
        sys.exit(1)
