#!/usr/bin/env python3

# Copyright (c) 2025 Base Core. All rights reserved.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at https://mozilla.org/MPL/2.0/.

import os
import sys
import subprocess
import glob
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
PATCHES_DIR = ROOT_DIR / 'patches'
CHROMIUM_DIR = ROOT_DIR.parent / 'src'

def log(message):
    """Print a log message."""
    print(f"[PATCH] {message}")

def exec_command(command, cwd=None, check=True):
    """Execute a shell command."""
    try:
        result = subprocess.run(
            command,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=check
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.CalledProcessError as e:
        return False, e.stdout, e.stderr

def check_chromium_dir():
    """Verify Chromium source directory exists."""
    if not CHROMIUM_DIR.exists():
        log(f"ERROR: Chromium source not found at {CHROMIUM_DIR}")
        log("Please run: npm run init")
        sys.exit(1)

def get_patch_files():
    """Get all .patch files from the patches directory."""
    if not PATCHES_DIR.exists():
        log(f"No patches directory found at {PATCHES_DIR}")
        return []

    patch_files = sorted(PATCHES_DIR.glob('*.patch'))
    return patch_files

def is_patch_applied(patch_file):
    """Check if a patch has already been applied."""
    # Try to apply in reverse to check if already applied
    command = f'git apply --reverse --check "{patch_file}"'
    success, _, _ = exec_command(command, cwd=CHROMIUM_DIR, check=False)
    return success

def apply_patch(patch_file):
    """Apply a single patch file."""
    patch_name = patch_file.name

    log(f"Checking {patch_name}...")

    if is_patch_applied(patch_file):
        log(f"  ✓ Already applied: {patch_name}")
        return True

    log(f"  Applying: {patch_name}")

    # Try to apply the patch
    command = f'git apply --whitespace=fix "{patch_file}"'
    success, stdout, stderr = exec_command(command, cwd=CHROMIUM_DIR, check=False)

    if success:
        log(f"  ✓ Successfully applied: {patch_name}")
        return True
    else:
        log(f"  ✗ Failed to apply: {patch_name}")
        log(f"  Error: {stderr}")

        # Try with 3-way merge
        log(f"  Attempting 3-way merge...")
        command = f'git apply --3way "{patch_file}"'
        success, stdout, stderr = exec_command(command, cwd=CHROMIUM_DIR, check=False)

        if success:
            log(f"  ✓ Applied with 3-way merge: {patch_name}")
            return True
        else:
            log(f"  ✗ 3-way merge failed: {patch_name}")
            log(f"  Error: {stderr}")
            return False

def unapply_all_patches():
    """Unapply all patches (for resetting)."""
    log("Unapplying all patches...")

    patch_files = get_patch_files()
    if not patch_files:
        log("No patches to unapply")
        return

    # Apply in reverse order
    for patch_file in reversed(patch_files):
        if is_patch_applied(patch_file):
            log(f"  Reverting: {patch_file.name}")
            command = f'git apply --reverse "{patch_file}"'
            exec_command(command, cwd=CHROMIUM_DIR, check=False)

def main():
    """Main function to apply all patches."""
    log("Base Core Patch Application")
    log("=" * 40)

    # Check if --reset flag is provided
    if '--reset' in sys.argv:
        unapply_all_patches()
        log("All patches unapplied")
        return

    # Verify Chromium directory
    check_chromium_dir()

    # Get patch files
    patch_files = get_patch_files()

    if not patch_files:
        log("No patches found in patches/")
        return

    log(f"Found {len(patch_files)} patch file(s)")
    log("")

    # Apply each patch
    success_count = 0
    failed_patches = []

    for patch_file in patch_files:
        if apply_patch(patch_file):
            success_count += 1
        else:
            failed_patches.append(patch_file.name)

    # Summary
    log("")
    log("=" * 40)
    log(f"Applied {success_count}/{len(patch_files)} patches successfully")

    if failed_patches:
        log("")
        log("Failed patches:")
        for patch in failed_patches:
            log(f"  ✗ {patch}")
        log("")
        log("Please resolve conflicts manually and re-run")
        sys.exit(1)
    else:
        log("")
        log("✓ All patches applied successfully!")

if __name__ == '__main__':
    main()
