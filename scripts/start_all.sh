#!/bin/bash
# ============================================================
#  AI Server in a Box - Start All Services
#  Start: Ollama, Docker WebUI, Jupyter, Dashboard, Creative Hub,
#         Playwright MCP, mcpo OpenAPI bridge
#
#  Designed to work BOTH from interactive shell and from a
#  LaunchAgent. All commands use absolute paths and an explicit
#  PATH so the non-interactive launchd environment (which gives
#  you only /usr/bin:/bin:/usr/sbin:/sbin by default) finds them.
#
#  Per-service logs go to ~/qa/logs/<service>.log so failures
#  leave a trace rather than dying silently into /dev/null.
#
#  Run manually:   bash scripts/start_all.sh
#  Re-run anytime: yes — every service is idempotent.
# ============================================================

set -u

# --- Hard PATH so npx, uvx, ollama, docker are found from launchd context ---
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/admin/.local/bin

# --- Absolute paths to every binary we touch ---
OLLAMA=/usr/local/bin/ollama
DOCKER=/usr/local/bin/docker
NPX=/usr/local/bin/npx
UVX=/Users/admin/.local/bin/uvx
SYS_PYTHON3=/usr/bin/python3
VENV_PYTHON=/Users/admin/ai-ecosystem/venv/bin/python
VENV_JUPYTER=/Users/admin/ai-ecosystem/venv/bin/jupyter

# --- Log dir ---
LOGDIR="$HOME/qa/logs"
/bin/mkdir -p "$LOGDIR"

ts() { /bin/date +"%Y-%m-%d %H:%M:%S"; }
log() { echo "[$(ts)] $*"; }

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Starting AI Server Services                 ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Auto-detect server IP — try en0 (ethernet) then en1 (wifi) then fall back
SERVER_IP=$(/usr/sbin/ipconfig getifaddr en0 2>/dev/null \
         || /usr/sbin/ipconfig getifaddr en1 2>/dev/null \
         || echo "localhost")

# Wait helper: spin up to N seconds for a TCP port to start listening.
# Used to verify each service actually came up.
wait_for_port() {
    local port=$1
    local timeout=${2:-15}
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if /usr/sbin/lsof -iTCP:"$port" -sTCP:LISTEN -P -n >/dev/null 2>&1; then
            return 0
        fi
        /bin/sleep 1
        elapsed=$((elapsed + 1))
    done
    return 1
}

# ============================================================
# 1. Ollama
# ============================================================
log "[1/7] Starting Ollama..."
if wait_for_port 11434 1; then
    log "      ℹ Ollama already listening on 11434"
else
    /usr/bin/env OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" \
        /usr/bin/nohup "$OLLAMA" serve >> "$LOGDIR/ollama.log" 2>&1 &
    if wait_for_port 11434 10; then
        log "      ✓ Ollama started on 11434"
    else
        log "      ✗ Ollama failed to bind 11434 (see $LOGDIR/ollama.log)"
    fi
fi

# ============================================================
# 2. Open WebUI (Docker container)
# ============================================================
log "[2/7] Starting Open WebUI..."
if [ -x "$DOCKER" ] && "$DOCKER" info >/dev/null 2>&1; then
    if "$DOCKER" start open-webui >> "$LOGDIR/docker.log" 2>&1; then
        log "      ✓ Open WebUI container started (port 8080)"
    else
        log "      ⚠ Open WebUI: docker start failed (container missing? see $LOGDIR/docker.log)"
    fi
else
    log "      ⚠ Docker daemon not reachable — Open WebUI / n8n won't run"
fi

# ============================================================
# 3. Jupyter
# ============================================================
log "[3/7] Starting Jupyter..."
if wait_for_port 8888 1; then
    log "      ℹ Jupyter already listening on 8888"
elif [ -x "$VENV_JUPYTER" ]; then
    /usr/bin/nohup "$VENV_JUPYTER" notebook \
        --notebook-dir="$HOME/ai-ecosystem/notebooks" \
        --no-browser \
        --ip=0.0.0.0 \
        >> "$LOGDIR/jupyter.log" 2>&1 &
    if wait_for_port 8888 15; then
        log "      ✓ Jupyter started on 8888"
    else
        log "      ✗ Jupyter failed (see $LOGDIR/jupyter.log)"
    fi
else
    log "      ✗ Jupyter binary not found at $VENV_JUPYTER"
fi

# ============================================================
# 4. Main Dashboard (port 9090)
# ============================================================
log "[4/7] Starting Dashboard..."
if wait_for_port 9090 1; then
    log "      ℹ Dashboard already listening on 9090"
elif [ -d "$HOME/ai-ecosystem/dashboard" ]; then
    cd "$HOME/ai-ecosystem/dashboard"
    /usr/bin/nohup "$SYS_PYTHON3" -m http.server 9090 \
        >> "$LOGDIR/dashboard.log" 2>&1 &
    if wait_for_port 9090 5; then
        log "      ✓ Dashboard started on 9090"
    else
        log "      ✗ Dashboard failed (see $LOGDIR/dashboard.log)"
    fi
else
    log "      ✗ Dashboard dir missing: $HOME/ai-ecosystem/dashboard"
fi

# ============================================================
# 5. Creative Hub (port 9091)
# ============================================================
log "[5/7] Starting Creative Hub..."
if wait_for_port 9091 1; then
    log "      ℹ Creative Hub already listening on 9091"
elif [ -d "$HOME/ai-ecosystem/creative-hub" ]; then
    cd "$HOME/ai-ecosystem/creative-hub"
    /usr/bin/nohup "$SYS_PYTHON3" -m http.server 9091 \
        >> "$LOGDIR/creative-hub.log" 2>&1 &
    if wait_for_port 9091 5; then
        log "      ✓ Creative Hub started on 9091"
    else
        log "      ✗ Creative Hub failed (see $LOGDIR/creative-hub.log)"
    fi
else
    log "      ✗ Creative Hub dir missing: $HOME/ai-ecosystem/creative-hub"
fi

# ============================================================
# 6. Playwright MCP (port 8931)
# ============================================================
log "[6/7] Starting Playwright MCP..."
if wait_for_port 8931 1; then
    log "      ℹ Playwright MCP already listening on 8931"
elif [ -x "$NPX" ]; then
    /usr/bin/nohup "$NPX" -y @playwright/mcp@latest \
        --port 8931 --host 0.0.0.0 --allowed-hosts "*" --headless \
        >> "$LOGDIR/playwright-mcp.log" 2>&1 &
    if wait_for_port 8931 25; then
        log "      ✓ Playwright MCP started on 8931"
    else
        log "      ✗ Playwright MCP failed (see $LOGDIR/playwright-mcp.log)"
    fi
else
    log "      ✗ npx not found at $NPX"
fi

# ============================================================
# 7. mcpo — OpenAPI bridge wrapping Playwright MCP
# ============================================================
log "[7/7] Starting mcpo..."
if wait_for_port 8932 1; then
    log "      ℹ mcpo already listening on 8932"
elif [ -x "$UVX" ]; then
    /usr/bin/nohup "$UVX" mcpo \
        --port 8932 --host 0.0.0.0 \
        --api-key "${MCPO_KEY:-mcpo-yakub-2026}" \
        --server-type streamable-http \
        -- http://localhost:8931/mcp \
        >> "$LOGDIR/mcpo.log" 2>&1 &
    if wait_for_port 8932 25; then
        log "      ✓ mcpo started on 8932"
    else
        log "      ✗ mcpo failed (see $LOGDIR/mcpo.log)"
    fi
else
    log "      ✗ uvx not found at $UVX"
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  start_all.sh complete                       ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  AI Chat:        http://localhost:8080       ║"
echo "║  Jupyter:        http://localhost:8888       ║"
echo "║  Dashboard:      http://localhost:9090       ║"
echo "║  Creative Hub:   http://localhost:9091       ║"
echo "║  Ollama API:     http://localhost:11434      ║"
echo "║  Playwright MCP: http://localhost:8931/mcp   ║"
echo "║  mcpo (OpenAPI): http://localhost:8932/docs  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Server IP: $SERVER_IP"
echo "Per-service logs: $LOGDIR/*.log"
echo ""
