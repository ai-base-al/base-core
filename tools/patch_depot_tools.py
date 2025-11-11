#!/usr/bin/env python3
"""
Patch depot_tools to fix Python 3.14 compatibility issues
This directly modifies the problematic files in depot_tools
"""

import os
import sys
import re

def patch_gclient_eval(depot_tools_path):
    """Patch gclient_eval.py to handle Python 3.14 ast changes"""

    gclient_eval_path = os.path.join(depot_tools_path, "gclient_eval.py")

    if not os.path.exists(gclient_eval_path):
        print(f"Warning: {gclient_eval_path} not found")
        return False

    print(f"Patching {gclient_eval_path}...")

    with open(gclient_eval_path, 'r') as f:
        content = f.read()

    # Backup original
    backup_path = gclient_eval_path + '.orig'
    if not os.path.exists(backup_path):
        with open(backup_path, 'w') as f:
            f.write(content)

    # Replace the problematic ast.Str check
    # The original code checks: if isinstance(node, ast.Str):
    # We need to replace it with a check for ast.Constant with string value

    replacements = [
        # Line 319: if isinstance(node, ast.Str):
        (
            r'if isinstance\(node, ast\.Str\):',
            'if isinstance(node, ast.Constant) and isinstance(node.value, str):'
        ),
        # Line 321: if isinstance(node, ast.Num):
        (
            r'if isinstance\(node, ast\.Num\):',
            'if isinstance(node, ast.Constant) and isinstance(node.value, (int, float, complex)):'
        ),
        # Line 323: if isinstance(node, ast.NameConstant):
        (
            r'if isinstance\(node, ast\.NameConstant\):',
            'if isinstance(node, ast.Constant) and node.value in (True, False, None):'
        ),
        # Also handle any direct references to ast.Str, ast.Num, etc.
        (
            r'ast\.Str\b',
            'ast.Constant'
        ),
        (
            r'ast\.Num\b',
            'ast.Constant'
        ),
        (
            r'ast\.NameConstant\b',
            'ast.Constant'
        ),
    ]

    modified = False
    for pattern, replacement in replacements:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            content = new_content
            modified = True
            print(f"  Applied patch: {pattern[:30]}...")

    if modified:
        with open(gclient_eval_path, 'w') as f:
            f.write(content)
        print(f"  Successfully patched {gclient_eval_path}")
        return True
    else:
        print(f"  No changes needed in {gclient_eval_path}")
        return False

def patch_all_python_shebangs(depot_tools_path):
    """Change all Python shebangs to use python3.13"""

    print(f"Patching Python shebangs in {depot_tools_path}...")

    count = 0
    for root, dirs, files in os.walk(depot_tools_path):
        for filename in files:
            if filename.endswith('.py') or filename in ['gclient', 'gclient.py', 'git-cl', 'fetch']:
                filepath = os.path.join(root, filename)
                try:
                    with open(filepath, 'r') as f:
                        first_line = f.readline()
                        if first_line.startswith('#!') and 'python' in first_line:
                            content = first_line + f.read()
                            new_first_line = '#!/usr/bin/env python3.13\n'
                            if first_line != new_first_line:
                                new_content = new_first_line + content[len(first_line):]
                                with open(filepath, 'w') as f:
                                    f.write(new_content)
                                count += 1
                except:
                    pass

    print(f"  Updated {count} files to use python3.13")
    return count > 0

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 patch_depot_tools.py <depot_tools_path>")
        sys.exit(1)

    depot_tools_path = sys.argv[1]

    if not os.path.exists(depot_tools_path):
        print(f"Error: {depot_tools_path} does not exist")
        sys.exit(1)

    print(f"Patching depot_tools at: {depot_tools_path}")
    print()

    # Apply both patches
    eval_patched = patch_gclient_eval(depot_tools_path)
    shebangs_patched = patch_all_python_shebangs(depot_tools_path)

    if eval_patched or shebangs_patched:
        print("\n✓ depot_tools patched successfully!")
        return 0
    else:
        print("\n✓ depot_tools already patched or no changes needed")
        return 0

if __name__ == "__main__":
    sys.exit(main())