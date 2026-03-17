#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"
WITH_AGENTS=0
REPO_NAME=""

usage() {
    echo -e "${YELLOW}Usage: new-repo.sh [--with-agents] <repo-name>${NC}"
    echo "Examples:"
    echo "  new-repo.sh my-awesome-project"
    echo "  new-repo.sh --with-agents my-shared-project"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-agents)
            WITH_AGENTS=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo -e "${YELLOW}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
        *)
            if [[ -n "$REPO_NAME" ]]; then
                echo -e "${YELLOW}Only one repo name is supported.${NC}"
                usage
                exit 1
            fi
            REPO_NAME="$1"
            shift
            ;;
    esac
done

if [[ -z "$REPO_NAME" ]]; then
    usage
    exit 1
fi

REPO_PATH="$(pwd)/$REPO_NAME"
TOTAL_STEPS=6
if [[ $WITH_AGENTS -eq 1 ]]; then
    TOTAL_STEPS=7
fi
CURRENT_STEP=1

print_step() {
    echo ""
    echo -e "${BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}] $1...${NC}"
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

echo ""
echo -e "${BLUE}=== New Repo Setup Wizard ===${NC}"
echo ""
echo "This will create: $REPO_PATH"
if [[ $WITH_AGENTS -eq 1 ]]; then
    echo "Mode: include repo AGENTS.md + CLAUDE.md"
else
    echo "Mode: no repo AGENTS.md/CLAUDE.md (global config only)"
fi
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Step 1: Create directory
print_step "Creating directory"
mkdir -p "$REPO_PATH"
cd "$REPO_PATH"
echo -e "${GREEN}Created $REPO_PATH${NC}"

# Step 2: Git init
print_step "Initializing git"
git init
echo -e "${GREEN}Git initialized${NC}"

# Step 3 (optional): AGENTS.md + CLAUDE.md
if [[ $WITH_AGENTS -eq 1 ]]; then
    print_step "Creating AGENTS.md + CLAUDE.md"
    cp "$TEMPLATE_DIR/repo-agents.md" "$REPO_PATH/AGENTS.md"
    if ln -s "AGENTS.md" "$REPO_PATH/CLAUDE.md" 2>/dev/null; then
        echo -e "${GREEN}Created AGENTS.md and CLAUDE.md -> AGENTS.md symlink${NC}"
    else
        cp "$REPO_PATH/AGENTS.md" "$REPO_PATH/CLAUDE.md"
        echo -e "${GREEN}Created AGENTS.md and CLAUDE.md (copy fallback)${NC}"
    fi
fi

# Next step: Create empty .gitignore
print_step "Creating .gitignore"
touch "$REPO_PATH/.gitignore"
echo -e "${GREEN}Created .gitignore (empty)${NC}"

# Next step: Create docs folder
print_step "Creating docs folder"
mkdir -p "$REPO_PATH/docs"
touch "$REPO_PATH/docs/.gitkeep"
echo -e "${GREEN}Created docs/ with .gitkeep${NC}"

# Next step: Initial commit
print_step "Creating initial commit"
git add .
git commit -m "Initial commit"
echo -e "${GREEN}Committed${NC}"

# Last step: Push to GitHub
print_step "Creating GitHub repo"
echo ""
echo "Visibility options:"
echo "  1) Public"
echo "  2) Private"
echo ""
read -p "Choose (1/2): " -n 1 -r VISIBILITY_CHOICE
echo ""

if [[ $VISIBILITY_CHOICE == "1" ]]; then
    VISIBILITY="public"
else
    VISIBILITY="private"
fi

read -p "Create $VISIBILITY repo '$REPO_NAME' on GitHub? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh repo create "$REPO_NAME" --"$VISIBILITY" --source=. --push
    echo -e "${GREEN}Pushed to GitHub${NC}"
else
    echo -e "${YELLOW}Skipped GitHub creation. You can run later:${NC}"
    echo "  gh repo create $REPO_NAME --private --source=. --push"
fi

# Done
echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Your new repo is ready at: $REPO_PATH"
echo ""
echo "Structure:"
echo "  $REPO_NAME/"
echo "  ├── .git/"
echo "  ├── .gitignore"
if [[ $WITH_AGENTS -eq 1 ]]; then
    echo "  ├── AGENTS.md"
    echo "  ├── CLAUDE.md -> AGENTS.md"
fi
echo "  └── docs/"
echo "      └── .gitkeep"
echo ""
