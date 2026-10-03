#!/usr/bin/env bash
set -euo pipefail

# Install the autonomous agent workflow into a target project.
# Usage: ./install.sh /path/to/your/project
# Or:    curl -fsSL <raw-url>/install.sh | bash -s -- /path/to/your/project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"

if [ "$TARGET" = "." ]; then
    echo "Usage: ./install.sh /path/to/your/project"
    echo ""
    echo "This will copy the autonomous agent workflow files into your project."
    echo "It will NOT overwrite existing files unless you pass --force."
    echo ""
    read -p "Install into current directory ($(pwd))? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    TARGET="$(pwd)"
fi

FORCE=false
if [ "${2:-}" = "--force" ]; then
    FORCE=true
fi

TARGET="$(cd "$TARGET" && pwd)"
echo "Installing autonomous agent workflow into: $TARGET"

copy_if_not_exists() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ -f "$dest" ] && [ "$FORCE" = false ]; then
        echo "  SKIP (exists): $dest"
    else
        cp "$src" "$dest"
        echo "  COPY: $dest"
    fi
}

# Copy .claude/agents
echo ""
echo "Copying agent definitions..."
for f in "$SCRIPT_DIR/.claude/agents/"*.md; do
    name="$(basename "$f")"
    copy_if_not_exists "$f" "$TARGET/.claude/agents/$name"
done

# Copy .claude/commands
echo ""
echo "Copying commands..."
for f in "$SCRIPT_DIR/.claude/commands/"*.md; do
    name="$(basename "$f")"
    copy_if_not_exists "$f" "$TARGET/.claude/commands/$name"
done

# Copy .claude/skills (if any)
if [ -d "$SCRIPT_DIR/.claude/skills" ] && [ "$(ls -A "$SCRIPT_DIR/.claude/skills/" 2>/dev/null)" ]; then
    echo ""
    echo "Copying skills..."
    for f in "$SCRIPT_DIR/.claude/skills/"*.md; do
        name="$(basename "$f")"
        copy_if_not_exists "$f" "$TARGET/.claude/skills/$name"
    done
fi

# Create project_memory structure
echo ""
echo "Creating project memory structure..."
mkdir -p "$TARGET/project_memory/architecture"
mkdir -p "$TARGET/project_memory/adrs"
mkdir -p "$TARGET/project_memory/contracts"
mkdir -p "$TARGET/project_memory/schemas"
mkdir -p "$TARGET/project_memory/known_issues"

copy_if_not_exists "$SCRIPT_DIR/project_memory/active_objective.md" "$TARGET/project_memory/active_objective.md"
copy_if_not_exists "$SCRIPT_DIR/project_memory/module_status.md" "$TARGET/project_memory/module_status.md"

# Create checkpoints directory
echo ""
echo "Creating checkpoints directory..."
mkdir -p "$TARGET/checkpoints/run"
touch "$TARGET/checkpoints/.gitkeep"

# Copy CLAUDE.md if it doesn't exist, otherwise append
if [ ! -f "$TARGET/CLAUDE.md" ]; then
    copy_if_not_exists "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
else
    echo ""
    echo "  NOTE: $TARGET/CLAUDE.md already exists."
    echo "  You may want to manually add the /dev-team documentation from this template's CLAUDE.md."
fi

# Add to .gitignore
if [ -f "$TARGET/.gitignore" ]; then
    if ! grep -q "checkpoints/" "$TARGET/.gitignore" 2>/dev/null; then
        echo "" >> "$TARGET/.gitignore"
        echo "# Autonomous agent run checkpoints (optional - remove to track run history)" >> "$TARGET/.gitignore"
        echo "checkpoints/" >> "$TARGET/.gitignore"
        echo "  UPDATED: .gitignore (added checkpoints/)"
    fi
else
    echo "# Autonomous agent run checkpoints (optional - remove to track run history)" > "$TARGET/.gitignore"
    echo "checkpoints/" >> "$TARGET/.gitignore"
    echo "  CREATED: .gitignore"
fi

echo ""
echo "Done! The autonomous agent workflow is installed."
echo ""
echo "Next steps:"
echo "  1. Edit project_memory/active_objective.md with your goal"
echo "  2. Run /dev-team in Claude Code to start"
echo "  3. Or: /dev-team Build a REST API with authentication"
