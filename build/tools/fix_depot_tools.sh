#!/bin/bash
# Fix depot_tools to use Python 3.11
DEPOT_TOOLS="$1"
if [ -f "$DEPOT_TOOLS/gclient" ]; then
  sed -i '' '1s|#!/usr/bin/env python3|#!/usr/bin/env python3.11|' "$DEPOT_TOOLS/gclient"
  sed -i '' '1s|#!/usr/bin/env python3|#!/usr/bin/env python3.11|' "$DEPOT_TOOLS/gclient.py" 2>/dev/null
  sed -i '' '1s|#!/usr/bin/env python3|#!/usr/bin/env python3.11|' "$DEPOT_TOOLS/gclient_eval.py" 2>/dev/null
  echo "Fixed depot_tools to use Python 3.11"
fi
