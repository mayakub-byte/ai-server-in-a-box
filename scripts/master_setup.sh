#!/bin/bash
# ============================================================
#  AI Server in a Box - MASTER SETUP
#  Open-source AI ecosystem for local development
#
#  Just run: bash scripts/master_setup.sh
#
#  It will execute all sprints one by one.
#  If something fails, fix it and run again —
#  completed steps will be skipped automatically.
# ============================================================

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG="$BASE_DIR/setup_log.txt"
PROGRESS="$BASE_DIR/.setup_progress"

# Auto-detect server IP (macOS)
SERVER_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "localhost")

# Create progress tracker
touch "$PROGRESS"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

is_done() {
    grep -q "$1" "$PROGRESS" 2>/dev/null
}

mark_done() {
    echo "$1" >> "$PROGRESS"
    log "COMPLETED: $1"
}

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     AI Server in a Box - MASTER SETUP       ║"
echo "║     Open-Source AI Development Stack        ║"
echo "║                                              ║"
echo "║     Server IP: $SERVER_IP                     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
log "Starting master setup..."

# ============================================================
# SPRINT 0: Prerequisites (Homebrew + Docker)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 0: Prerequisites"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Homebrew
if ! command -v brew &> /dev/null; then
    if ! is_done "homebrew"; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for Intel Mac
        eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        mark_done "homebrew"
    fi
else
    log "Homebrew already installed"
    mark_done "homebrew"
fi

# Ensure brew is in PATH
eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null

# Python 3
if ! command -v python3 &> /dev/null; then
    log "Installing Python 3..."
    brew install python3
fi
mark_done "python3"

# Node.js
if ! command -v node &> /dev/null; then
    log "Installing Node.js..."
    brew install node
fi
mark_done "nodejs"

# Docker
if ! command -v docker &> /dev/null; then
    if ! is_done "docker_installed"; then
        log "Installing Docker..."
        brew install --cask docker
        mark_done "docker_installed"
    fi
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    log "Starting Docker..."
    open /Applications/Docker.app
    echo ""
    echo "⏳ Docker is starting for the first time..."
    echo "   Waiting for Docker to be ready (this can take 1-2 minutes)..."
    echo ""

    DOCKER_WAIT=0
    while ! docker info &> /dev/null; do
        sleep 5
        DOCKER_WAIT=$((DOCKER_WAIT + 5))
        echo "   Waiting... ($DOCKER_WAIT seconds)"
        if [ $DOCKER_WAIT -gt 180 ]; then
            log "ERROR: Docker took too long to start."
            echo "Please start Docker manually and run this script again."
            exit 1
        fi
    done
fi
log "Docker is running"
mark_done "docker"

echo "✅ Sprint 0 complete — all prerequisites installed"

# ============================================================
# SPRINT 1: Ollama + Open WebUI (AI Chat Interface)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 1: Ollama + Open WebUI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Configure Ollama for network access
if ! is_done "ollama_network"; then
    log "Configuring Ollama for network access..."
    launchctl setenv OLLAMA_HOST 0.0.0.0
    launchctl setenv OLLAMA_ORIGINS "*"

    # Create LaunchAgent for Ollama auto-start
    mkdir -p ~/Library/LaunchAgents
    cat > ~/Library/LaunchAgents/com.ollama.serve.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.serve</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>0.0.0.0</string>
        <key>OLLAMA_ORIGINS</key>
        <string>*</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
PLIST
    mark_done "ollama_network"
fi

# Restart Ollama with network access
log "Restarting Ollama with network access..."
pkill -f "ollama serve" 2>/dev/null
sleep 2
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" ollama serve &
sleep 5

# Pull AI models
if ! is_done "models_pulled"; then
    log "Pulling AI models (this takes time)..."
    ollama pull gemma3:4b
    log "Gemma 3 4B done"
    ollama pull llama3.1:8b
    log "Llama 3.1 8B done"
    ollama pull codellama:7b
    log "CodeLlama 7B done"
    ollama pull mistral:7b
    log "Mistral 7B done"
    mark_done "models_pulled"
else
    log "Models already pulled"
fi

# Open WebUI
if ! docker ps | grep -q open-webui; then
    log "Starting Open WebUI..."
    docker rm -f open-webui 2>/dev/null
    docker pull ghcr.io/open-webui/open-webui:main
    docker run -d \
        --name open-webui \
        -p 8080:8080 \
        --add-host=host.docker.internal:host-gateway \
        -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
        --restart always \
        ghcr.io/open-webui/open-webui:main
    mark_done "open_webui"
else
    log "Open WebUI already running"
fi

echo "✅ Sprint 1 complete"
echo "   → Open WebUI: http://$SERVER_IP:8080"
echo "   → Ollama API: http://$SERVER_IP:11434"

# ============================================================
# SPRINT 2: Google Gemini CLI (Optional)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 2: Google Gemini CLI (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! is_done "gemini_cli"; then
    log "Installing Gemini CLI and Google AI SDK..."
    npm install -g @anthropic-ai/gemini-cli 2>/dev/null || npm install -g @google/gemini-cli 2>/dev/null

    # Install Google AI SDK for Python
    pip3 install --break-system-packages google-generativeai 2>/dev/null || pip3 install google-generativeai

    # Create Gemini test script
    cat > "$BASE_DIR/test_gemini.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Test Gemini API connection.
Set your API key: export GOOGLE_API_KEY="your-key-here"
Get a key from: https://aistudio.google.com/apikey
"""
import os
try:
    import google.generativeai as genai
    api_key = os.environ.get("GOOGLE_API_KEY", "")
    if not api_key:
        print("⚠️  No API key found.")
        print("   1. Go to https://aistudio.google.com/apikey")
        print("   2. Create a free API key")
        print("   3. Run: export GOOGLE_API_KEY='your-key-here'")
        print("   4. Run this script again")
    else:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-2.0-flash')
        response = model.generate_content("Say hello and tell me you're working!")
        print("✅ Gemini is working!")
        print(f"Response: {response.text}")
except ImportError:
    print("Installing google-generativeai...")
    os.system("pip3 install google-generativeai")
    print("Done! Run this script again.")
PYEOF

    mark_done "gemini_cli"
else
    log "Gemini CLI already set up"
fi

echo "✅ Sprint 2 complete"
echo "   → Get API key: https://aistudio.google.com/apikey"
echo "   → Test: python3 '$BASE_DIR/test_gemini.py'"

# ============================================================
# SPRINT 3: Python AI Development Environment
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 3: AI Development Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! is_done "ai_dev_env"; then
    log "Setting up AI development environment..."

    # Create project directory
    mkdir -p ~/ai-ecosystem/{agents,research,design,video,data}

    # Create Python virtual environment
    python3 -m venv ~/ai-ecosystem/venv
    source ~/ai-ecosystem/venv/bin/activate

    # Install core AI packages
    pip install --upgrade pip
    pip install \
        google-generativeai \
        langchain \
        langchain-google-genai \
        openai \
        requests \
        flask \
        fastapi \
        uvicorn \
        pandas \
        numpy \
        jupyter \
        notebook \
        streamlit \
        gradio \
        Pillow \
        httpx

    log "AI packages installed"

    # Create activation shortcut
    cat > ~/ai-ecosystem/activate.sh << 'ACTEOF'
#!/bin/bash
source ~/ai-ecosystem/venv/bin/activate
export OLLAMA_HOST=0.0.0.0
export GOOGLE_API_KEY="YOUR_KEY_HERE"
echo "AI ecosystem environment activated!"
echo "Available tools: python, ollama, streamlit, jupyter, gradio"
ACTEOF
    chmod +x ~/ai-ecosystem/activate.sh

    mark_done "ai_dev_env"
else
    log "AI dev environment already set up"
fi

echo "✅ Sprint 3 complete"
echo "   → Activate: source ~/ai-ecosystem/activate.sh"

# ============================================================
# SPRINT 4: AI Agents
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 4: AI Agents"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! is_done "ai_agents"; then
    log "Setting up AI agents..."
    source ~/ai-ecosystem/venv/bin/activate 2>/dev/null

    # Copy agent scripts from the agents directory
    mkdir -p ~/ai-ecosystem/agents

    # Product Research Agent
    cp "$SCRIPT_DIR/../agents/product_research_agent.py" ~/ai-ecosystem/agents/ 2>/dev/null
    # Data Agent
    cp "$SCRIPT_DIR/../agents/data_agent.py" ~/ai-ecosystem/agents/ 2>/dev/null
    # Orchestrator
    cp "$SCRIPT_DIR/../agents/orchestrator.py" ~/ai-ecosystem/agents/ 2>/dev/null

    chmod +x ~/ai-ecosystem/agents/*.py
    mark_done "ai_agents"
else
    log "AI agents already set up"
fi

echo "✅ Sprint 4 complete"
echo "   → Research: python3 ~/ai-ecosystem/agents/product_research_agent.py 'AI trends 2026'"
echo "   → Data: python3 ~/ai-ecosystem/agents/data_agent.py 'analyze sales data'"
echo "   → Orchestrator: python3 ~/ai-ecosystem/agents/orchestrator.py 'your question'"

# ============================================================
# SPRINT 5: Jupyter Notebook Server
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 5: Jupyter Notebook Server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! is_done "jupyter"; then
    log "Setting up Jupyter Notebook server..."
    source ~/ai-ecosystem/venv/bin/activate 2>/dev/null

    # Generate Jupyter config
    jupyter notebook --generate-config -y 2>/dev/null

    # Configure for network access
    cat > ~/.jupyter/jupyter_notebook_config.py << 'JUPEOF'
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.token = 'ai-server-token'
c.NotebookApp.allow_remote_access = True
JUPEOF

    # Create starter notebook
    mkdir -p ~/ai-ecosystem/notebooks
    cat > ~/ai-ecosystem/notebooks/welcome.py << 'NBEOF'
# Welcome to your AI Ecosystem!
#
# Available tools:
# - Ollama (local AI models)
# - Google Generative AI
# - Pandas, NumPy (data analysis)
# - Streamlit, Gradio (web apps)
#
# Quick test:
import requests
response = requests.get("http://localhost:11434/api/tags")
models = [m["name"] for m in response.json().get("models", [])]
print(f"Available AI models: {models}")
NBEOF

    mark_done "jupyter"
else
    log "Jupyter already set up"
fi

# Start Jupyter in background
source ~/ai-ecosystem/venv/bin/activate 2>/dev/null
nohup jupyter notebook --notebook-dir=~/ai-ecosystem/notebooks &>/dev/null &

echo "✅ Sprint 5 complete"
echo "   → Jupyter: http://$SERVER_IP:8888 (token: ai-server-token)"

# ============================================================
# SPRINT 6: Monitoring Dashboard
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 6: Monitoring Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! is_done "dashboard"; then
    log "Creating monitoring dashboard..."

    cat > ~/ai-ecosystem/dashboard.html << 'DASHEOF'
<!DOCTYPE html>
<html>
<head>
    <title>AI Server Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0f172a; color: #e2e8f0; padding: 20px; }
        h1 { text-align: center; font-size: 24px; margin-bottom: 20px; color: #38bdf8; }
        .subtitle { text-align: center; color: #64748b; margin-bottom: 30px; font-size: 14px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; max-width: 1200px; margin: 0 auto; }
        .card { background: #1e293b; border-radius: 12px; padding: 20px; border: 1px solid #334155; }
        .card h2 { font-size: 16px; color: #94a3b8; margin-bottom: 12px; }
        .status { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
        .dot { width: 10px; height: 10px; border-radius: 50%; }
        .dot.green { background: #22c55e; box-shadow: 0 0 8px #22c55e; }
        .dot.red { background: #ef4444; box-shadow: 0 0 8px #ef4444; }
        .dot.yellow { background: #eab308; }
        a { color: #38bdf8; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .models { margin-top: 12px; }
        .model-tag { display: inline-block; background: #334155; padding: 4px 10px; border-radius: 6px; margin: 2px; font-size: 13px; }
        .refresh { text-align: center; margin-top: 20px; color: #64748b; font-size: 13px; }
        .links { margin-top: 12px; }
        .links a { display: block; margin: 4px 0; font-size: 14px; }
    </style>
</head>
<body>
    <h1>🖥️ AI Server in a Box</h1>
    <p class="subtitle">Open-source AI development stack</p>

    <div class="grid">
        <div class="card">
            <h2>🤖 Ollama</h2>
            <div class="status" id="ollama-status">
                <div class="dot yellow"></div>
                <span>Checking...</span>
            </div>
            <div class="links">
                <a href="http://localhost:11434" target="_blank">API Endpoint</a>
            </div>
            <div class="models" id="ollama-models"></div>
        </div>

        <div class="card">
            <h2>💬 Open WebUI</h2>
            <div class="status" id="webui-status">
                <div class="dot yellow"></div>
                <span>Checking...</span>
            </div>
            <div class="links">
                <a href="http://localhost:8080" target="_blank">Open Chat Interface</a>
            </div>
        </div>

        <div class="card">
            <h2>📓 Jupyter Notebooks</h2>
            <div class="status" id="jupyter-status">
                <div class="dot yellow"></div>
                <span>Checking...</span>
            </div>
            <div class="links">
                <a href="http://localhost:8888/?token=ai-server-token" target="_blank">Open Notebooks</a>
            </div>
        </div>

        <div class="card">
            <h2>🔗 Quick Access</h2>
            <div class="links">
                <a href="http://localhost:8080" target="_blank">💬 Chat with AI</a>
                <a href="http://localhost:8888/?token=ai-server-token" target="_blank">📓 Jupyter Notebooks</a>
                <a href="http://localhost:11434/api/tags" target="_blank">🤖 List AI Models</a>
                <a href="https://aistudio.google.com" target="_blank">🔬 Google AI Studio</a>
            </div>
        </div>

        <div class="card">
            <h2>🛠️ AI Agents</h2>
            <div class="links">
                <a>📊 Product Research Agent</a>
                <a>🗄️ Data Analysis Agent</a>
                <a>🎯 Multi-Agent Orchestrator</a>
            </div>
            <p style="margin-top:8px;font-size:13px;color:#64748b;">Run via Terminal: python3 ~/ai-ecosystem/agents/orchestrator.py</p>
        </div>

        <div class="card">
            <h2>📋 System Info</h2>
            <div id="system-info" style="font-size:13px;color:#94a3b8;">
                <p>AI Server in a Box</p>
                <p>Open-Source Edition</p>
                <p id="server-ip"></p>
                <p id="uptime"></p>
            </div>
        </div>
    </div>

    <p class="refresh">Auto-refreshes every 30 seconds | <span id="last-update"></span></p>

    <script>
        async function checkService(url, statusId) {
            try {
                await fetch(url, { mode: 'no-cors', signal: AbortSignal.timeout(5000) });
                document.getElementById(statusId).innerHTML = '<div class="dot green"></div><span>Online</span>';
                return true;
            } catch(e) {
                document.getElementById(statusId).innerHTML = '<div class="dot red"></div><span>Offline</span>';
                return false;
            }
        }

        async function loadModels() {
            try {
                const resp = await fetch('http://localhost:11434/api/tags');
                const data = await resp.json();
                const models = data.models || [];
                document.getElementById('ollama-models').innerHTML =
                    models.map(m => `<span class="model-tag">${m.name}</span>`).join('');
            } catch(e) {}
        }

        async function refresh() {
            await checkService('http://localhost:11434', 'ollama-status');
            await checkService('http://localhost:8080', 'webui-status');
            await checkService('http://localhost:8888', 'jupyter-status');
            await loadModels();
            document.getElementById('last-update').textContent = new Date().toLocaleTimeString();
            document.getElementById('server-ip').textContent = 'localhost - or local network IP';
        }

        refresh();
        setInterval(refresh, 30000);
    </script>
</body>
</html>
DASHEOF

    # Serve dashboard
    mkdir -p ~/ai-ecosystem/dashboard
    cp ~/ai-ecosystem/dashboard.html ~/ai-ecosystem/dashboard/index.html

    mark_done "dashboard"
else
    log "Dashboard already set up"
fi

# Start dashboard server
cd ~/ai-ecosystem/dashboard
nohup python3 -m http.server 9090 &>/dev/null &

echo "✅ Sprint 6 complete"
echo "   → Dashboard: http://localhost:9090"

# ============================================================
# SPRINT 7: Auto-Start Everything on Boot
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 7: Auto-Start Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! is_done "autostart"; then
    log "Creating auto-start script..."

    cat > ~/ai-ecosystem/start_all.sh << 'STARTEOF'
#!/bin/bash
# Start all AI server services
echo "Starting AI Server in a Box services..."

# Ollama
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" ollama serve &
sleep 3

# Open WebUI (Docker)
docker start open-webui 2>/dev/null

# Jupyter
source ~/ai-ecosystem/venv/bin/activate
nohup jupyter notebook --notebook-dir=~/ai-ecosystem/notebooks &>/dev/null &

# Dashboard
cd ~/ai-ecosystem/dashboard
nohup python3 -m http.server 9090 &>/dev/null &

echo ""
echo "All services started!"
echo "  💬 Chat:      http://localhost:8080"
echo "  📓 Jupyter:   http://localhost:8888"
echo "  📊 Dashboard: http://localhost:9090"
echo "  🤖 Ollama:    http://localhost:11434"
STARTEOF
    chmod +x ~/ai-ecosystem/start_all.sh

    mark_done "autostart"
else
    log "Auto-start already configured"
fi

echo "✅ Sprint 7 complete"
echo "   → Manual start: ~/ai-ecosystem/start_all.sh"

# ============================================================
# FINAL: Summary
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     🎉 SETUP COMPLETE! 🎉                   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Your AI Server is ready!"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│  SERVICE          URL                        │"
echo "├─────────────────────────────────────────────┤"
echo "│  💬 AI Chat       http://localhost:8080     │"
echo "│  📓 Jupyter       http://localhost:8888     │"
echo "│  📊 Dashboard     http://localhost:9090     │"
echo "│  🤖 Ollama API    http://localhost:11434    │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "Jupyter token: ai-server-token"
echo ""
echo "AI Models installed:"
ollama list 2>/dev/null
echo ""
echo "Start all services: bash ~/ai-ecosystem/start_all.sh"
echo ""
echo "Log saved to: $LOG"
echo ""
log "Master setup completed successfully!"
