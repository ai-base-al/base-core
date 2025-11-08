#!/usr/bin/env python3
"""
Fix Python 3.14 compatibility for depot_tools
Monkey-patches ast module to restore removed attributes
"""

import ast
import sys

# In Python 3.14, ast.Str, ast.Num, etc. were removed
# They're now just ast.Constant
# We restore them for backward compatibility

if not hasattr(ast, 'Str'):
    print("Applying Python 3.14 compatibility patch for ast module...")

    # Create wrapper classes that behave like the old ones
    class Str(ast.Constant):
        def __init__(self, s, **kwargs):
            super().__init__(value=s, **kwargs)
            self.s = s

    class Num(ast.Constant):
        def __init__(self, n, **kwargs):
            super().__init__(value=n, **kwargs)
            self.n = n

    class NameConstant(ast.Constant):
        def __init__(self, value, **kwargs):
            super().__init__(value=value, **kwargs)

    # Patch the ast module
    ast.Str = Str
    ast.Num = Num
    ast.NameConstant = NameConstant

    # Also patch isinstance to handle these correctly
    original_isinstance = isinstance

    def patched_isinstance(obj, classinfo):
        if classinfo == ast.Str:
            return original_isinstance(obj, ast.Constant) and original_isinstance(obj.value, str)
        elif classinfo == ast.Num:
            return original_isinstance(obj, ast.Constant) and original_isinstance(obj.value, (int, float, complex))
        elif classinfo == ast.NameConstant:
            return original_isinstance(obj, ast.Constant) and obj.value in (True, False, None)
        return original_isinstance(obj, classinfo)

    # Replace isinstance in the builtins
    import builtins
    builtins.isinstance = patched_isinstance

    print("Python 3.14 ast compatibility patch applied successfully!")
else:
    print("ast.Str exists - no patch needed")

# Now import and run the actual script
if __name__ == "__main__":
    import sys
    import os

    # Get the script to run from command line
    if len(sys.argv) > 1:
        script_path = sys.argv[1]
        # Remove our script from argv
        sys.argv = [script_path] + sys.argv[2:]

        # Execute the script
        with open(script_path, 'r') as f:
            code = compile(f.read(), script_path, 'exec')
            exec(code, {'__file__': script_path, '__name__': '__main__'})