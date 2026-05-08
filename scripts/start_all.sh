#!/bin/bash
# ============================================================
#  AI Server in a Box - Start All Services
#  Start: Ollama, Docker WebUI, Jupyter, Dashboard, Creative Hub
#
#  Run: bash scripts/start_all.sh
# ============================================================

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  Starting AI Server Services                 ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Auto-detect server IP
SERVER_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "localhost")

# Source environment
source ~/.zshrc 2>/dev/null

echo "Starting services..."
echo ""

# 1. Ollama (AI model server)
echo "[1/5] Starting Ollama..."
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" ollama serve &
sleep 3
echo "      ✓ Ollama started on port 11434"

# 2. Open WebUI (Docker - AI chat interface)
echo "[2/5] Starting Open WebUI..."
docker start open-webui 2>/dev/null
if [ $? -eq 0 ]; then
    echo "      ✓ Open WebUI started on port 8080"
else
    echo "      ℹ Open WebUI container not found (first run?)"
fi

# 3. Jupyter Notebooks
echo "[3/5] Starting Jupyter..."
source ~/ai-ecosystem/venv/bin/activate 2>/dev/null
nohup jupyter notebook --notebook-dir=~/ai-ecosystem/notebooks &>/dev/null &
echo "      ✓ Jupyter started on port 8888"

# 4. Main Dashboard (port 9090)
echo "[4/5] Starting Dashboard..."
cd ~/ai-ecosystem/dashboard 2>/dev/null
nohup python3 -m http.server 9090 &>/dev/null &
echo "      ✓ Dashboard started on port 9090"

# 5. Creative Hub (port 9091)
echo "[5/6] Starting Creative Hub..."
cd ~/ai-ecosystem/creative-hub 2>/dev/null
nohup python3 -m http.server 9091 &>/dev/null &
echo "      ✓ Creative Hub started on port 9091"

# 6. Playwright MCP (port 8931) - browser automation MCP server
echo "[6/6] Starting Playwright MCP..."
mkdir -p ~/qa/logs
if pgrep -f "@playwright/mcp" >/dev/null 2>&1; then
    echo "      ℹ Playwright MCP already running"
else
    nohup npx -y @playwright/mcp@latest \
        --port 8931 --host 0.0.0.0 --allowed-hosts "*" --headless \
        > ~/qa/logs/playwright-mcp.log 2>&1 &
    echo "      ✓ Playwright MCP started on port 8931"
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  All Services Running!                       ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  AI Chat:        http://localhost:8080       ║"
echo "║  Jupyter:        http://localhost:8888       ║"
echo "║                (token: ai-server-token)      ║"
echo "║  Dashboard:      http://localhost:9090       ║"
echo "║  Creative Hub:   http://localhost:9091       ║"
echo "║  Ollama API:     http://localhost:11434      ║"
echo "║  Playwright MCP: http://localhost:8931/mcp   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Optional: Start ComfyUI (image generation)"
echo "  bash ~/ai-ecosystem/design/start_comfyui.sh"
echo ""
echo "Server IP: $SERVER_IP"
echo ""
