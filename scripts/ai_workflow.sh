#!/bin/bash
# ============================================================
#  AI Workflow Helper
#  Start any stage of the Idea-to-Live pipeline
#  Usage: bash ai_workflow.sh <project-name> <stage>
# ============================================================

PROJECT_NAME="$1"
STAGE="$2"
PROJECT_DIR=~/projects/"$PROJECT_NAME"
CONTEXT_FILE="$PROJECT_DIR/CONTEXT.md"
SHARED="/Volumes/CoWork - Conenct iMac"

if [ -z "$PROJECT_NAME" ] || [ -z "$STAGE" ]; then
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║  AI Workflow — Idea to Live Pipeline          ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "Usage: bash ai_workflow.sh <project-name> <stage>"
    echo ""
    echo "Stages:"
    echo "  1-idea        Explore an idea with local LLM (FREE)"
    echo "  2-research    Deep research with Llama 3.1 (FREE)"
    echo "  3-prototype   Quick prototype with CodeLlama (FREE)"
    echo "  4-iterate     Refine with local + Claude Code (MIX)"
    echo "  5-build       Production build with Claude Code (PAID)"
    echo "  6-golive      Deploy and monitor (MIX)"
    echo "  status        Show current project stage"
    echo ""
    echo "Example:"
    echo "  bash ai_workflow.sh my-saas-app 1-idea"
    echo ""
    exit 0
fi

# Create project directory if needed
mkdir -p "$PROJECT_DIR"

# Copy context template if no CONTEXT.md exists
if [ ! -f "$CONTEXT_FILE" ]; then
    if [ -f "$SHARED/CONTEXT_TEMPLATE.md" ]; then
        cp "$SHARED/CONTEXT_TEMPLATE.md" "$CONTEXT_FILE"
        sed -i '' "s/\[Project Name\]/$PROJECT_NAME/g" "$CONTEXT_FILE" 2>/dev/null
        sed -i '' "s/\[Date\]/$(date '+%Y-%m-%d')/g" "$CONTEXT_FILE" 2>/dev/null
        echo "Created CONTEXT.md for $PROJECT_NAME"
    else
        echo "# PROJECT CONTEXT: $PROJECT_NAME" > "$CONTEXT_FILE"
        echo "Created basic CONTEXT.md"
    fi
fi

# Function to append to session log
log_session() {
    local tool="$1"
    local action="$2"
    echo "[$(date '+%Y-%m-%d %H:%M')] [$tool] $action" >> "$CONTEXT_FILE"
}

case "$STAGE" in

    1-idea)
        echo ""
        echo "━━━ STAGE 1: IDEA (FREE — Local LLM) ━━━"
        echo ""
        echo "Starting idea exploration with Gemma 3..."
        echo "Context file: $CONTEXT_FILE"
        echo ""

        # Update stage in context
        sed -i '' "s/\*\*Stage:\*\*.*/\*\*Stage:\*\* IDEA/" "$CONTEXT_FILE" 2>/dev/null

        ollama run gemma3:4b "You are a product strategist. I'm going to describe an idea. Help me evaluate it by answering:
1. What problem does this solve?
2. Who is the target user?
3. What already exists in this space?
4. Is this worth building? Why or why not?
5. What's the simplest version (MVP) we could build?

Read any context I provide and be direct. Ask me to describe my idea."

        log_session "Gemma 4B" "Idea exploration session"
        ;;

    2-research)
        echo ""
        echo "━━━ STAGE 2: RESEARCH (FREE — Local LLM) ━━━"
        echo ""
        echo "Starting deep research with Llama 3.1..."
        echo ""

        sed -i '' "s/\*\*Stage:\*\*.*/\*\*Stage:\*\* RESEARCH/" "$CONTEXT_FILE" 2>/dev/null

        ollama run llama3.1:8b "You are a market researcher and technical architect. Read the following project context, then provide:
1. Market size and growth potential
2. Top 3 competitors and their weaknesses
3. Recommended tech stack with justification
4. Architecture diagram (text-based)
5. Key risks and mitigation strategies
6. Go/No-Go recommendation

Here is the project context:
$(cat "$CONTEXT_FILE")

Provide your analysis:"

        log_session "Llama 3.1 8B" "Market research and technical analysis"
        ;;

    3-prototype)
        echo ""
        echo "━━━ STAGE 3: PROTOTYPE (FREE — Local LLM) ━━━"
        echo ""
        echo "Starting prototype generation with CodeLlama..."
        echo ""

        sed -i '' "s/\*\*Stage:\*\*.*/\*\*Stage:\*\* PROTOTYPE/" "$CONTEXT_FILE" 2>/dev/null

        cd "$PROJECT_DIR"

        ollama run codellama:7b "You are a rapid prototyping engineer. Read the following project context and generate:
1. A working prototype — minimal but functional
2. File structure
3. Key code files with full implementations
4. Instructions to run it locally

Keep it simple. Use Python/Flask or Node/Express. No over-engineering.

Here is the project context:
$(cat "$CONTEXT_FILE")

Generate the prototype code:"

        log_session "CodeLlama 7B" "Prototype generation"
        ;;

    4-iterate)
        echo ""
        echo "━━━ STAGE 4: ITERATE (MIX — Local + Claude Code) ━━━"
        echo ""
        echo "Two options:"
        echo "  a) Small fixes — use local LLM (free)"
        echo "  b) Complex logic — use Claude Code (paid)"
        echo ""

        sed -i '' "s/\*\*Stage:\*\*.*/\*\*Stage:\*\* ITERATE/" "$CONTEXT_FILE" 2>/dev/null

        echo "For local fixes:"
        echo "  ollama run codellama:7b \"Fix: [describe the issue]\""
        echo ""
        echo "For Claude Code (complex work):"
        echo "  cd $PROJECT_DIR"
        echo "  claude \"Read CONTEXT.md first, then: [your task]\""
        echo ""

        log_session "Mixed" "Iteration stage started"
        ;;

    5-build)
        echo ""
        echo "━━━ STAGE 5: BUILD (PAID — Claude Code) ━━━"
        echo ""
        echo "Production build with Claude Code..."
        echo ""

        sed -i '' "s/\*\*Stage:\*\*.*/\*\*Stage:\*\* BUILD/" "$CONTEXT_FILE" 2>/dev/null

        cd "$PROJECT_DIR"

        echo "Running Claude Code for production build..."
        echo ""
        echo "Command:"
        echo "  cd $PROJECT_DIR"
        echo "  claude \"Read CONTEXT.md for full project history. Now harden this for production:"
        echo "    1. Add comprehensive error handling"
        echo "    2. Write unit tests (aim for 80%+ coverage)"
        echo "    3. Add input validation and security"
        echo "    4. Add logging and monitoring hooks"
        echo "    5. Write deployment documentation"
        echo "    6. Create Dockerfile if applicable\""
        echo ""

        log_session "Claude Code" "Production build stage started"
        ;;

    6-golive)
        echo ""
        echo "━━━ STAGE 6: GO LIVE (MIX) ━━━"
        echo ""

        sed -i '' "s/\*\*Stage:\*\*.*/\*\*Stage:\*\* LIVE/" "$CONTEXT_FILE" 2>/dev/null

        echo "Deployment checklist:"
        echo "  [ ] All tests passing"
        echo "  [ ] Environment variables set"
        echo "  [ ] Database migrated"
        echo "  [ ] SSL configured"
        echo "  [ ] Monitoring set up"
        echo "  [ ] Backup strategy in place"
        echo "  [ ] README updated"
        echo ""
        echo "Post-deploy monitoring (free, local LLM):"
        echo "  ollama run gemma3:4b \"Analyze these logs for issues: [paste logs]\""
        echo ""

        log_session "Mixed" "Go-live stage started"
        ;;

    status)
        echo ""
        echo "╔══════════════════════════════════════════════╗"
        echo "║  Project: $PROJECT_NAME"
        echo "╚══════════════════════════════════════════════╝"
        echo ""
        grep "Stage:" "$CONTEXT_FILE" 2>/dev/null || echo "No stage set"
        echo ""
        echo "Session Log:"
        echo "━━━━━━━━━━━━"
        tail -20 "$CONTEXT_FILE" 2>/dev/null
        echo ""
        ;;

    *)
        echo "Unknown stage: $STAGE"
        echo "Use: 1-idea, 2-research, 3-prototype, 4-iterate, 5-build, 6-golive, status"
        ;;
esac
