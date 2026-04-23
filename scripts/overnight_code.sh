#!/bin/bash
# ============================================================
#  AI Server in a Box - Overnight Code Review Agent
#  Review all code repos automatically
#
#  Run: bash scripts/overnight_code.sh
# ============================================================

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$BASE_DIR/code_reviews_$(date '+%Y%m%d')"
LOG="$REPORT_DIR/review_log.txt"

# Load API keys
source ~/.zshrc 2>/dev/null
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"

mkdir -p "$REPORT_DIR"
mkdir -p ~/projects

echo "" | tee -a "$LOG"
echo "╔══════════════════════════════════════════════╗" | tee -a "$LOG"
echo "║  Overnight Code Review Agent                 ║" | tee -a "$LOG"
echo "║  Started: $(date '+%Y-%m-%d %H:%M:%S')                  ║" | tee -a "$LOG"
echo "╚══════════════════════════════════════════════╝" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# Check if gh is available
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI not found. Install with: brew install gh" | tee -a "$LOG"
    exit 1
fi

# Get all repos
echo "Fetching repo list from GitHub..." | tee -a "$LOG"
REPOS=$(gh repo list --limit 100 --json nameWithOwner,url --jq '.[].nameWithOwner' 2>/dev/null)

if [ -z "$REPOS" ]; then
    echo "ERROR: Could not fetch repos. Make sure 'gh auth login' was completed." | tee -a "$LOG"
    exit 1
fi

TOTAL=$(echo "$REPOS" | wc -l | tr -d ' ')
echo "Found $TOTAL repos to review" | tee -a "$LOG"
echo "" | tee -a "$LOG"

REPO_NUM=0

echo "$REPOS" | while IFS= read -r repo; do
    [ -z "$repo" ] && continue

    REPO_NUM=$((REPO_NUM + 1))
    REPO_NAME=$(basename "$repo")
    REVIEW_FILE="$REPORT_DIR/${REPO_NAME}_review.md"

    echo "" | tee -a "$LOG"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
    echo "  [$REPO_NUM/$TOTAL] Reviewing: $repo" | tee -a "$LOG"
    echo "  Started: $(date '+%H:%M:%S')" | tee -a "$LOG"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"

    # Clone if not already cloned
    cd ~/projects
    if [ ! -d "$REPO_NAME" ]; then
        echo "  Cloning $repo..." | tee -a "$LOG"
        gh repo clone "$repo" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "  SKIP: Failed to clone $repo" | tee -a "$LOG"
            echo "# $REPO_NAME - Clone Failed" > "$REVIEW_FILE"
            continue
        fi
    else
        echo "  Already cloned, pulling latest..." | tee -a "$LOG"
        cd "$REPO_NAME" && git pull 2>/dev/null
        cd ~/projects
    fi

    # Run Claude Code review
    cd ~/projects/"$REPO_NAME"

    echo "  Running code review..." | tee -a "$LOG"

    # Check if ANTHROPIC_API_KEY is set
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo "  SKIP: ANTHROPIC_API_KEY not set. Run: bash scripts/set_api_keys.sh" | tee -a "$LOG"
        echo "# $REPO_NAME - Skipped (API key not set)" > "$REVIEW_FILE"
        continue
    fi

    # Run Claude Code review
    claude --print "Review this codebase thoroughly. Provide:

1. **Project Summary** - What this project does, tech stack, size
2. **Architecture** - How the code is organized
3. **Code Quality Scorecard** (rate each 1-10):
   - Architecture
   - Security
   - Type Safety
   - Error Handling
   - Test Coverage
   - Code Quality
   - Performance
   - Documentation
   - Overall
4. **Critical Issues** - Bugs, security vulnerabilities, breaking issues
5. **Top 10 Improvements** - Prioritized list (do now / do next / do later)
6. **Positive Highlights** - What's done well

Format as clean markdown." > "$REVIEW_FILE" 2>&1

    echo "  Review saved to: $REVIEW_FILE" | tee -a "$LOG"
    echo "  Completed: $(date '+%H:%M:%S')" | tee -a "$LOG"

    cd ~/projects
done

# Generate summary report
echo "" | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
echo "  Generating Summary Report..." | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"

cat > "$REPORT_DIR/SUMMARY.md" << SUMEOF
# Code Review Summary - All Repos
**Date:** $(date '+%Y-%m-%d')
**Reviewed by:** Claude Code (Anthropic)

## Repos Reviewed
SUMEOF

for review_file in "$REPORT_DIR"/*_review.md; do
    [ -f "$review_file" ] || continue
    repo_name=$(basename "$review_file" _review.md)
    echo "- [$repo_name](./${repo_name}_review.md)" >> "$REPORT_DIR/SUMMARY.md"
done

cat >> "$REPORT_DIR/SUMMARY.md" << SUMEOF2

## Individual Reviews
See each *_review.md file for detailed analysis.

## Next Steps
1. Read each review
2. Fix critical/security issues first
3. Use Claude Code to auto-fix: \`cd ~/projects/repo-name && claude "Fix the top security issues"\`
SUMEOF2

echo "" | tee -a "$LOG"
echo "╔══════════════════════════════════════════════╗" | tee -a "$LOG"
echo "║  Overnight Review Complete!                   ║" | tee -a "$LOG"
echo "║  Finished: $(date '+%Y-%m-%d %H:%M:%S')             ║" | tee -a "$LOG"
echo "╚══════════════════════════════════════════════╝" | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "Reports saved to: $REPORT_DIR" | tee -a "$LOG"
echo "Open SUMMARY.md for the overview" | tee -a "$LOG"
echo "" | tee -a "$LOG"
