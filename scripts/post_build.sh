#!/bin/bash
# Post-Build Git Workflow
# Runs after successful build completion

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CORE_DIR="$(dirname "$SCRIPT_DIR")"

cd "$BASE_CORE_DIR"

echo "Post-Build Git Workflow"
echo "======================="
echo ""

# Check if build completed successfully
if [ ! -f ".build_complete" ]; then
    echo "ERROR: Build completion marker not found"
    echo "Run this script only after build completes"
    exit 1
fi

echo "Step 1: Committing build artifacts and new scripts to main"
git checkout main
git add scripts/build_continue.sh
git add scripts/keep_disk_active.sh
git add scripts/monitor_build.sh
git add scripts/post_build.sh
git add .gitignore  # In case we added entries

git commit -m "Add build continuation and monitoring scripts

- build_continue.sh: Resume build from configured state (skip unpacking)
- keep_disk_active.sh: Prevent external disk disconnection during build
- monitor_build.sh: Track build progress every 30 minutes
- post_build.sh: Automated post-build git workflow

Built bindgen from source (7.1MB)
Successfully completed ungoogled-chromium build with 54,696 targets

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo ""
echo "Step 2: Cleaning up stale branches"
# List all branches except main and feature/ai-assistant-sidepanel
echo "Current branches:"
git branch -a

# Delete merged branches (interactive)
echo ""
read -p "Delete merged branches? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "feature/ai-assistant-sidepanel" | xargs -n 1 git branch -d
fi

echo ""
echo "Step 3: Creating branch for progress/ features"
echo ""
echo "Available features in progress/:"
ls -1 progress/current/ progress/future/ 2>/dev/null || echo "No features found"

echo ""
read -p "Enter feature name (from progress/) or 'skip' to skip: " feature_name

if [ "$feature_name" != "skip" ] && [ -n "$feature_name" ]; then
    branch_name="feature/${feature_name}"

    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "Branch $branch_name already exists. Checking out..."
        git checkout "$branch_name"
    else
        echo "Creating new branch: $branch_name"
        git checkout -b "$branch_name"

        # Copy progress doc to branch
        if [ -f "progress/current/${feature_name}.md" ]; then
            echo "Feature found in progress/current/"
            git add "progress/current/${feature_name}.md"
            git commit -m "Start implementing ${feature_name}

From progress/current/${feature_name}.md

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        elif [ -f "progress/future/${feature_name}.md" ]; then
            echo "Feature found in progress/future/"
            git add "progress/future/${feature_name}.md"
            git commit -m "Start implementing ${feature_name}

From progress/future/${feature_name}.md

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        fi
    fi
fi

echo ""
echo "=========================================="
echo "Post-build workflow complete!"
echo "=========================================="
echo ""
echo "Current branch: $(git branch --show-current)"
echo ""
echo "To push changes:"
echo "  git push origin main"
if [ "$feature_name" != "skip" ] && [ -n "$feature_name" ]; then
    echo "  git push origin $branch_name"
fi
