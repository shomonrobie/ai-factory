#!/usr/bin/env python3
"""
Master Orchestration Script for AI Software Factory
"""

import os
import sys
import subprocess
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
import traceback

def print_header():
    """Print application header"""
    print("\n" + "=" * 60)
    print("AI SOFTWARE FACTORY - MASTER SETUP")
    print("=" * 60 + "\n")

def pre_fix_batch_files():
    """Pre-fix batch files before execution"""
    print("[1] Pre-fixing batch files...")
    
    for i in range(1, 6):
        batch_file = f"generate_batch{i}.py"
        if not Path(batch_file).exists():
            continue
        
        with open(batch_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Fix triple double quotes
        content = content.replace('"""', '\\"\\"\\"')
        
        # Fix missing colons after function definitions
        lines = content.split('\n')
        fixed_lines = []
        for line in lines:
            if 'def ' in line and not line.rstrip().endswith(':'):
                if '):' not in line and line.strip() and not line.strip().startswith('#'):
                    line = line.rstrip() + ':'
            fixed_lines.append(line)
        content = '\n'.join(fixed_lines)
        
        if content != original:
            with open(batch_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  Fixed: {batch_file}")
    
    print("[OK] Pre-fix complete\n")

def fix_python_file(filepath):
    """Fix common issues in a Python file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Fix triple quotes
        content = content.replace('"""', '\\"\\"\\"')
        content = content.replace("'''", "\\'\\'\\'")
        
        # Fix missing colons
        lines = content.split('\n')
        fixed_lines = []
        for line in lines:
            if line.strip().startswith('def ') and not line.rstrip().endswith(':'):
                line = line.rstrip() + ':'
            if line.strip().startswith('if ') and not line.rstrip().endswith(':'):
                if line.strip().endswith(':'):
                    pass
                elif ':' not in line:
                    line = line.rstrip() + ':'
            fixed_lines.append(line)
        content = '\n'.join(fixed_lines)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"  Error fixing {filepath}: {e}")
        return False

def execute_batch(batch_file, batch_num, temp_dir):
    """Execute a single batch file"""
    print(f"\n[{batch_num}] Executing: {batch_file}")
    print("-" * 40)
    
    result = {
        "success": False,
        "errors": [],
        "output": []
    }
    
    try:
        # Read and fix the batch file
        with open(batch_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Fix common issues
        content = content.replace('"""', '\\"\\"\\"')
        content = content.replace("'''", "\\'\\'\\'")
        
        # Write fixed version
        fixed_file = temp_dir / f"fixed_{batch_file}"
        with open(fixed_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Execute
        env = os.environ.copy()
        env['PYTHONIOENCODING'] = 'utf-8'
        
        process = subprocess.Popen(
            [sys.executable, str(fixed_file)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
            cwd=str(Path.cwd()),
            encoding='utf-8',
            errors='replace'
        )
        
        stdout, stderr = process.communicate(timeout=300)
        
        if stdout:
            result["output"] = stdout.split('\n')
            for line in stdout.split('\n')[:3]:
                if line.strip():
                    print(f"  {line[:80]}")
        
        if stderr:
            result["errors"].extend(stderr.split('\n'))
        
        if process.returncode == 0:
            result["success"] = True
            print(f"  [OK] Batch {batch_num} completed")
        else:
            print(f"  [FAIL] Batch {batch_num} failed (code: {process.returncode})")
            if stderr:
                print(f"  Error: {stderr[:200]}")
    
    except subprocess.TimeoutExpired:
        result["errors"].append("Timeout after 5 minutes")
        print(f"  [FAIL] Batch {batch_num} timed out")
    except Exception as e:
        result["errors"].append(str(e))
        print(f"  [FAIL] Batch {batch_num} error: {str(e)[:100]}")
    
    return result

def main():
    """Main execution function"""
    print_header()
    
    # Check for batch files
    batch_files = [f"generate_batch{i}.py" for i in range(1, 6)]
    missing = [f for f in batch_files if not Path(f).exists()]
    
    if missing:
        print(f"ERROR: Missing batch files: {missing}")
        print("Please ensure all 5 batch files are in the current directory")
        sys.exit(1)
    
    print(f"Found batch files: {batch_files}\n")
    
    # Pre-fix batch files
    pre_fix_batch_files()
    
    # Create temp directory
    temp_dir = tempfile.mkdtemp(prefix="factory_batch_")
    print(f"Temp directory: {temp_dir}\n")
    
    results = {}
    start_time = datetime.now()
    
    try:
        # Execute batches in order
        for i, batch_file in enumerate(batch_files, 1):
            result = execute_batch(batch_file, i, Path(temp_dir))
            results[i] = result
            
            # Stop on critical failure
            if not result["success"] and i <= 2:
                print(f"\n[STOP] Critical batch {i} failed. Aborting.")
                break
            
            # Small delay between batches
            import time
            time.sleep(2)
    
    finally:
        # Cleanup
        if Path(temp_dir).exists():
            shutil.rmtree(temp_dir)
            print(f"\n[INFO] Cleaned up temp directory")
    
    # Print summary
    print("\n" + "=" * 60)
    print("EXECUTION SUMMARY")
    print("=" * 60)
    
    successful = sum(1 for r in results.values() if r.get("success", False))
    total = len(results)
    
    print(f"Successful batches: {successful}/{total}")
    print(f"Time elapsed: {(datetime.now() - start_time).total_seconds():.2f} seconds")
    print("")
    
    if successful == 5:
        print("SUCCESS! All batches executed successfully!")
        print("\nNext steps:")
        print("  1. Run: python validate_system.py")
        print("  2. Run: docker-compose up -d")
        print("  3. Access: http://localhost:8000/docs")
    elif successful >= 3:
        print("WARNING: Partial success - some batches failed")
        print("Check the errors above and try running again")
    else:
        print("ERROR: Setup failed - multiple batches failed")
        print("\nTroubleshooting steps:")
        print("  1. Check Python version (3.8+ required)")
        print("  2. Ensure all batch files are complete")
        print("  3. Run: python quick_fix.py")
    
    print("=" * 60)
    
    # Exit with appropriate code
    sys.exit(0 if successful >= 4 else 1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[INFO] Setup interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n[ERROR] Fatal error: {str(e)}")
        traceback.print_exc()
        sys.exit(1)