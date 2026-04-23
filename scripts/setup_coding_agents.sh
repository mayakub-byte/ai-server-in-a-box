#!/bin/bash
# ============================================================
#  AI Server in a Box - Coding Agents Setup
#  Claude Code + LLM CLI for autonomous coding
#
#  Run: bash scripts/setup_coding_agents.sh
# ============================================================

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG="$BASE_DIR/setup_log.txt"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Coding Agents Setup                         ║"
echo "║  Claude Code + LLM CLI                       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ============================================================
# STEP 1: Prerequisites (Git, Node.js, npm)
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 1: Prerequisites"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Ensure brew is in PATH
eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null

# Git
if command -v git &> /dev/null; then
    echo "  Git: $(git --version)"
else
    log "Installing Git..."
    brew install git
fi

# Node.js (needed for Claude Code)
if command -v node &> /dev/null; then
    echo "  Node.js: $(node --version)"
else
    log "Installing Node.js..."
    brew install node
fi

# npm
if command -v npm &> /dev/null; then
    echo "  npm: $(npm --version)"
else
    echo "  npm not found - should come with Node.js"
fi

echo "  Prerequisites ready"

# ============================================================
# STEP 2: Configure Git
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 2: Git Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Set git config if not already set
CURRENT_NAME=$(git config --global user.name 2>/dev/null)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -z "$CURRENT_NAME" ]; then
    echo "  Git name not set. Using git config..."
    git config --global user.name "AI Server User"
    echo "  Set git name: AI Server User"
else
    echo "  Git name: $CURRENT_NAME"
fi

if [ -z "$CURRENT_EMAIL" ]; then
    echo "  Git email not set. Please configure:"
    echo "    git config --global user.email 'your-email@example.com'"
else
    echo "  Git email: $CURRENT_EMAIL"
fi

# ============================================================
# STEP 3: GitHub CLI (for repo access)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 3: GitHub CLI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v gh &> /dev/null; then
    log "Installing GitHub CLI..."
    brew install gh
    echo "  GitHub CLI installed"
else
    echo "  GitHub CLI: $(gh --version | head -1)"
fi

# Check if already authenticated
if gh auth status &> /dev/null; then
    echo "  GitHub: Already authenticated"
else
    echo ""
    echo "  You need to log in to GitHub."
    echo "  Run this command after the script finishes:"
    echo ""
    echo "    gh auth login"
    echo ""
    echo "  Choose: GitHub.com → HTTPS → Yes → Login with browser"
    echo ""
fi

# ============================================================
# STEP 4: Claude Code
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 4: Claude Code"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v claude &> /dev/null; then
    log "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    echo "  Claude Code installed"
else
    echo "  Claude Code: already installed"
fi

# Check for API key
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "  Anthropic API key: Set"
else
    echo ""
    echo "  You need to set your Anthropic API key:"
    echo ""
    echo "  1. Go to: https://console.anthropic.com/settings/keys"
    echo "  2. Copy your API key"
    echo "  3. Run: export ANTHROPIC_API_KEY='YOUR_KEY_HERE'"
    echo "  4. Add to ~/.zshrc or ~/.bash_profile to persist"
    echo ""
fi

# ============================================================
# STEP 5: Create Projects Directory
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 5: Projects Directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p ~/projects
echo "  Projects directory: ~/projects"
echo "  Clone your repos here, then use Claude Code"

# ============================================================
# STEP 6: Create Helper Scripts
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Step 6: Helper Scripts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Claude Code task runner
cat > ~/ai-ecosystem/run_claude_task.sh << 'CLAUDEEOF'
#!/bin/bash
# ============================================
# Run Claude Code on a repo with a task
#
# Usage:
#   bash ~/ai-ecosystem/run_claude_task.sh /path/to/repo "your task description"
#
# Example:
#   bash ~/ai-ecosystem/run_claude_task.sh ~/projects/my-app "Add user authentication"
# ============================================

REPO_PATH="$1"
TASK="$2"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$REPO_PATH/claude_task_${TIMESTAMP}.log"

if [ -z "$REPO_PATH" ] || [ -z "$TASK" ]; then
    echo "Usage: bash run_claude_task.sh /path/to/repo \"task description\""
    exit 1
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    source ~/.zshrc 2>/dev/null
fi

echo "Starting Claude Code task..."
echo "  Repo: $REPO_PATH"
echo "  Task: $TASK"
echo "  Log:  $LOG_FILE"
echo ""

cd "$REPO_PATH"

# Run Claude Code with the task, log output
claude --print "$TASK" 2>&1 | tee "$LOG_FILE"

echo ""
echo "Task complete. Log saved to: $LOG_FILE"
echo "Review changes: cd $REPO_PATH && git diff"
CLAUDEEOF
chmod +x ~/ai-ecosystem/run_claude_task.sh

# Overnight coding script
cat > ~/ai-ecosystem/overnight_code.sh << 'OVERNIGHTEOF'
#!/bin/bash
# ============================================
# Overnight Coding Agent
#
# Give it a repo and a task list — it works
# through them while you sleep.
#
# Usage:
#   bash ~/ai-ecosystem/overnight_code.sh ~/projects/my-app tasks.txt
#
# tasks.txt format (one task per line):
#   Add input validation to forms
#   Write unit tests for the module
#   Fix the pagination bug
# ============================================

REPO_PATH="$1"
TASKS_FILE="$2"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_DIR="$REPO_PATH/overnight_logs_${TIMESTAMP}"

if [ -z "$REPO_PATH" ] || [ -z "$TASKS_FILE" ]; then
    echo "Usage: bash overnight_code.sh /path/to/repo tasks.txt"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo "Tasks file not found: $TASKS_FILE"
    exit 1
fi

mkdir -p "$LOG_DIR"

if [ -z "$ANTHROPIC_API_KEY" ]; then
    source ~/.zshrc 2>/dev/null
fi

echo "╔══════════════════════════════════════════════╗"
echo "║  Overnight Coding Agent                      ║"
echo "║  Starting at $(date '+%H:%M:%S')                         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Repo: $REPO_PATH"
echo "Tasks file: $TASKS_FILE"
echo "Logs: $LOG_DIR"
echo ""

cd "$REPO_PATH"

# Create a branch for overnight work
BRANCH="overnight-${TIMESTAMP}"
git checkout -b "$BRANCH" 2>/dev/null

TASK_NUM=0
TOTAL=$(wc -l < "$TASKS_FILE" | tr -d ' ')

while IFS= read -r task; do
    # Skip empty lines and comments
    [[ -z "$task" || "$task" == \#* ]] && continue

    TASK_NUM=$((TASK_NUM + 1))
    TASK_LOG="$LOG_DIR/task_${TASK_NUM}.log"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Task $TASK_NUM/$TOTAL: $task"
    echo "  Started: $(date '+%H:%M:%S')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Run Claude Code
    claude --print "$task" 2>&1 | tee "$TASK_LOG"

    # Commit after each task
    git add -A
    git commit -m "Overnight agent: $task" 2>/dev/null

    echo "  Completed: $(date '+%H:%M:%S')"
    echo "  Log: $TASK_LOG"

done < "$TASKS_FILE"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Overnight coding complete!                  ║"
echo "║  Finished at $(date '+%H:%M:%S')                        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Branch: $BRANCH"
echo "Review: cd $REPO_PATH && git log --oneline $BRANCH"
echo "Diff:   cd $REPO_PATH && git diff main..$BRANCH"
echo "Logs:   $LOG_DIR"
echo ""
echo "If happy, merge: git checkout main && git merge $BRANCH"
OVERNIGHTEOF
chmod +x ~/ai-ecosystem/overnight_code.sh

# Quick clone helper
cat > ~/ai-ecosystem/clone_and_code.sh << 'CLONEEOF'
#!/bin/bash
# ============================================
# Clone a repo and start coding with Claude
#
# Usage:
#   bash ~/ai-ecosystem/clone_and_code.sh https://github.com/user/repo.git
# ============================================

REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
    echo "Usage: bash clone_and_code.sh <github-repo-url>"
    exit 1
fi

REPO_NAME=$(basename "$REPO_URL" .git)

cd ~/projects
git clone "$REPO_URL"
cd "$REPO_NAME"

echo ""
echo "Repo cloned to: ~/projects/$REPO_NAME"
echo ""
echo "Now you can:"
echo "  1. Start Claude Code interactively:"
echo "     cd ~/projects/$REPO_NAME && claude"
echo ""
echo "  2. Give it a single task:"
echo "     bash ~/ai-ecosystem/run_claude_task.sh ~/projects/$REPO_NAME \"your task\""
echo ""
echo "  3. Run overnight with a task list:"
echo "     bash ~/ai-ecosystem/overnight_code.sh ~/projects/$REPO_NAME tasks.txt"
echo ""
CLONEEOF
chmod +x ~/ai-ecosystem/clone_and_code.sh

echo "  Helper scripts created:"
echo "    ~/ai-ecosystem/run_claude_task.sh      — Single task runner"
echo "    ~/ai-ecosystem/overnight_code.sh       — Overnight multi-task agent"
echo "    ~/ai-ecosystem/clone_and_code.sh       — Clone repo and start coding"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  Coding Agents Setup Complete!                       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "NEXT STEPS:"
echo ""
echo "  1. Authenticate GitHub (if not done):"
echo "     gh auth login"
echo ""
echo "  2. Set Anthropic API key:"
echo "     Go to: https://console.anthropic.com/settings/keys"
echo "     Then: export ANTHROPIC_API_KEY='your-key'"
echo "     Add to ~/.zshrc or ~/.bash_profile"
echo ""
echo "  3. Clone a repo:"
echo "     bash ~/ai-ecosystem/clone_and_code.sh https://github.com/YOUR/REPO.git"
echo ""
echo "  4. Start coding interactively:"
echo "     cd ~/projects/your-repo && claude"
echo ""
echo "  5. Or run overnight:"
echo "     Create tasks.txt with one task per line"
echo "     bash ~/ai-ecosystem/overnight_code.sh ~/projects/your-repo tasks.txt"
echo ""
echo "  Go to sleep. Wake up to code."
echo ""
log "Coding agents setup completed"
