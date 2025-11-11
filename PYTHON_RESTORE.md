# Python 3.13 Temporary Switch

## What Was Changed
Temporarily switched `/opt/homebrew/bin/python3` symlink from Python 3.14 to Python 3.13 to resolve ungoogled-chromium build compatibility issues.

## Original Configuration
```bash
/opt/homebrew/bin/python3 -> ../Cellar/python@3.14/3.14.0_1/bin/python3
```

## Current Configuration
```bash
/opt/homebrew/bin/python3 -> ../Cellar/python@3.13/3.13.9_1/bin/python3.13
```

## How to Restore Python 3.14 (After Build Completes)
```bash
cd /opt/homebrew/bin
rm python3
ln -s ../Cellar/python@3.14/3.14.0_1/bin/python3.14 python3
python3 --version  # Should show Python 3.14.0
```

## Why This Was Necessary
ungoogled-chromium's `clone.py` script hardcodes `python3` calls to depot_tools, which bypasses the `PYTHON=python3.13` environment variable. This causes AST compatibility errors with Python 3.14 (ast.Str, ast.Num, ast.NameConstant were removed in 3.14).

## Build Status
Build started: 2025-11-10 18:12
Expected completion: 2-4 hours
Log file: `logs/build.log`

Monitor progress:
```bash
tail -f logs/build.log
```
