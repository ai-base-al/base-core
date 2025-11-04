# Dependency management for Base Core
# This file defines external dependencies and their versions

vars = {
  'chromium_version': '130.0.6723.116',
  'ungoogled_version': '130.0.6723.116-1',
}

deps = {
  # These dependencies will be managed by the sync script
  # Actual Chromium/ungoogled-chromium source will be downloaded via depot_tools
}

hooks = [
  {
    # Apply Base patches after sync
    'name': 'apply_patches',
    'pattern': '.',
    'action': ['python3', 'src/base/script/apply_patches.py'],
  },
  {
    # Update submodules
    'name': 'update_submodules',
    'pattern': '.',
    'action': ['git', 'submodule', 'update', '--init', '--recursive'],
  },
]
