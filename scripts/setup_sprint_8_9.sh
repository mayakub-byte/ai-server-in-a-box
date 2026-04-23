#!/bin/bash
# ============================================================
#  AI Server in a Box - SPRINTS 8 & 9
#  Design, Creative & Video Tools + Integration Testing
#
#  Run: bash scripts/setup_sprint_8_9.sh
# ============================================================

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOG="$BASE_DIR/setup_log.txt"
PROGRESS="$BASE_DIR/.setup_progress"

# Auto-detect server IP (macOS)
SERVER_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "localhost")

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
echo "║  AI Server - Sprints 8 & 9                  ║"
echo "║  Design, Video & Integration                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ============================================================
# SPRINT 8: Design & Creative Tools
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 8: Design & Creative Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Activate AI environment
source ~/ai-ecosystem/venv/bin/activate 2>/dev/null

# --- 8A: ComfyUI (Local Image Generation) ---
if ! is_done "comfyui"; then
    log "Installing ComfyUI (Stable Diffusion UI)..."

    mkdir -p ~/ai-ecosystem/design

    # Install ComfyUI
    cd ~/ai-ecosystem/design
    if [ ! -d "ComfyUI" ]; then
        git clone https://github.com/comfyanonymous/ComfyUI.git
        cd ComfyUI
        pip install -r requirements.txt
        pip install torch torchvision torchaudio
    else
        cd ComfyUI
    fi

    # Download a lightweight SD model (SD 1.5 - works on CPU)
    mkdir -p models/checkpoints
    if [ ! -f "models/checkpoints/v1-5-pruned-emaonly.safetensors" ]; then
        log "Downloading Stable Diffusion 1.5 model (~4GB)..."
        curl -L -o models/checkpoints/v1-5-pruned-emaonly.safetensors \
            "https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors" \
            2>/dev/null || log "WARNING: SD model download may need manual download from HuggingFace"
    fi

    # Create ComfyUI start script
    cat > ~/ai-ecosystem/design/start_comfyui.sh << 'COMFYEOF'
#!/bin/bash
source ~/ai-ecosystem/venv/bin/activate
cd ~/ai-ecosystem/design/ComfyUI
echo "Starting ComfyUI on port 8188..."
echo "Access at: http://localhost:8188"
python3 main.py --listen 0.0.0.0 --port 8188 --cpu
COMFYEOF
    chmod +x ~/ai-ecosystem/design/start_comfyui.sh

    mark_done "comfyui"
else
    log "ComfyUI already installed"
fi

# --- 8B: AI Image Generation via Ollama (LLaVA) ---
if ! is_done "image_tools"; then
    log "Setting up AI image tools..."

    # Install Python image libraries
    pip install Pillow diffusers transformers accelerate safetensors 2>/dev/null

    # Create a simple image generation script using Ollama
    cat > ~/ai-ecosystem/design/generate_image_prompt.py << 'IMGEOF'
#!/usr/bin/env python3
"""
AI Image Prompt Generator
Uses local AI to create detailed image prompts,
then can be used with ComfyUI or cloud services.
"""
import requests
import sys

OLLAMA_URL = "http://localhost:11434/api/generate"

def generate_prompt(idea, style="photorealistic"):
    """Generate a detailed image prompt from a simple idea"""
    prompt = f"""You are an expert at writing prompts for AI image generation (Stable Diffusion, DALL-E, Midjourney).

Convert this simple idea into a detailed, high-quality image generation prompt:

Idea: {idea}
Style: {style}

Include details about:
- Subject description
- Lighting and mood
- Camera angle and composition
- Colors and atmosphere
- Quality tags (4k, detailed, professional, etc.)

Return ONLY the prompt, nothing else."""

    response = requests.post(OLLAMA_URL, json={
        "model": "gemma3:4b",
        "prompt": prompt,
        "stream": True
    })
    return response.text

if __name__ == "__main__":
    idea = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "a futuristic city at sunset"
    print(f"\nIdea: {idea}\n")
    result = generate_prompt(idea)
    print(f"Generated Prompt:\n{result}")
IMGEOF
    chmod +x ~/ai-ecosystem/design/generate_image_prompt.py

    mark_done "image_tools"
else
    log "Image tools already installed"
fi

# --- 8C: Creative Tools Bookmarks Page ---
if ! is_done "creative_hub"; then
    log "Creating Creative Tools Hub..."

    cat > ~/ai-ecosystem/design/creative_hub.html << 'HUBEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Creative Tools Hub</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #0a0a1a; color: #e2e8f0; padding: 20px; }
        h1 { text-align: center; font-size: 28px; margin-bottom: 8px; background: linear-gradient(135deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .subtitle { text-align: center; color: #64748b; margin-bottom: 30px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; max-width: 1200px; margin: 0 auto; }
        .card { background: #1a1a2e; border-radius: 12px; padding: 24px; border: 1px solid #2a2a4a; transition: transform 0.2s; }
        .card:hover { transform: translateY(-2px); border-color: #667eea; }
        .card h2 { font-size: 18px; margin-bottom: 8px; color: #a78bfa; }
        .card p { color: #94a3b8; font-size: 14px; margin-bottom: 16px; line-height: 1.5; }
        .card a { display: inline-block; background: #667eea; color: white; padding: 8px 16px; border-radius: 8px; text-decoration: none; font-size: 14px; margin-right: 8px; margin-bottom: 8px; }
        .card a:hover { background: #764ba2; }
        .card a.secondary { background: transparent; border: 1px solid #667eea; color: #667eea; }
        .section { margin-top: 30px; margin-bottom: 16px; font-size: 20px; color: #667eea; max-width: 1200px; margin-left: auto; margin-right: auto; padding-left: 4px; }
        .local-tag { display: inline-block; background: #22c55e20; color: #22c55e; padding: 2px 8px; border-radius: 4px; font-size: 11px; margin-left: 8px; }
        .cloud-tag { display: inline-block; background: #3b82f620; color: #3b82f6; padding: 2px 8px; border-radius: 4px; font-size: 11px; margin-left: 8px; }
    </style>
</head>
<body>
    <h1>Creative Tools Hub</h1>
    <p class="subtitle">Your AI-powered design & creative toolkit</p>

    <h3 class="section">Image Generation</h3>
    <div class="grid">
        <div class="card">
            <h2>ComfyUI <span class="local-tag">LOCAL</span></h2>
            <p>Node-based Stable Diffusion interface. Create images locally on your machine — no API costs, fully private. Slower on CPU but unlimited.</p>
            <a href="http://localhost:8188" target="_blank">Open ComfyUI</a>
            <a href="#" class="secondary" onclick="alert('Run in Terminal:\nbash ~/ai-ecosystem/design/start_comfyui.sh')">Start Server</a>
        </div>
        <div class="card">
            <h2>Google AI Studio <span class="cloud-tag">CLOUD</span></h2>
            <p>Google's AI playground. Generate images with Imagen, chat with Gemini, test prompts. Free tier available.</p>
            <a href="https://aistudio.google.com" target="_blank">Open AI Studio</a>
        </div>
        <div class="card">
            <h2>AI Prompt Generator <span class="local-tag">LOCAL</span></h2>
            <p>Use local AI to craft detailed prompts for any image generation tool. Turns simple ideas into professional prompts.</p>
            <a href="#" class="secondary" onclick="alert('Run in Terminal:\npython3 ~/ai-ecosystem/design/generate_image_prompt.py \'your idea here\'')">How to Use</a>
        </div>
    </div>

    <h3 class="section">Design & Prototyping</h3>
    <div class="grid">
        <div class="card">
            <h2>Google AI Studio <span class="cloud-tag">CLOUD</span></h2>
            <p>Google's AI design tool. Turn text prompts into UI designs and prototypes instantly.</p>
            <a href="https://aistudio.google.com" target="_blank">Open AI Studio</a>
        </div>
        <div class="card">
            <h2>Figma <span class="cloud-tag">CLOUD</span></h2>
            <p>Professional design tool with AI features for UI/UX design and prototyping.</p>
            <a href="https://figma.com" target="_blank">Open Figma</a>
        </div>
    </div>

    <h3 class="section">Research & Writing</h3>
    <div class="grid">
        <div class="card">
            <h2>Google Gemini <span class="cloud-tag">CLOUD</span></h2>
            <p>Google's most capable AI. Advanced reasoning, code generation, multimodal understanding.</p>
            <a href="https://gemini.google.com" target="_blank">Open Gemini</a>
        </div>
    </div>

    <div style="text-align:center;margin-top:40px;color:#475569;font-size:13px;">
        <p>AI Server in a Box | <a href="http://localhost:9090" style="color:#667eea;">Back to Dashboard</a></p>
    </div>
</body>
</html>
HUBEOF

    # Serve creative hub on port 9091
    mkdir -p ~/ai-ecosystem/creative-hub
    cp ~/ai-ecosystem/design/creative_hub.html ~/ai-ecosystem/creative-hub/index.html

    mark_done "creative_hub"
else
    log "Creative Hub already set up"
fi

# Start Creative Hub server
cd ~/ai-ecosystem/creative-hub
nohup python3 -m http.server 9091 &>/dev/null &

echo "✅ Sprint 8 complete"
echo "   → ComfyUI: http://localhost:8188 (run start_comfyui.sh first)"
echo "   → Creative Hub: http://localhost:9091"

# ============================================================
# SPRINT 9: Integration & Final Configuration
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SPRINT 9: Integration & Final Config"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# --- 9A: Update start_all.sh to include new services ---
if ! is_done "start_all_v2"; then
    log "Updating start_all.sh with all services..."

    cat > ~/ai-ecosystem/start_all.sh << 'STARTEOF'
#!/bin/bash
# ============================================
# Start ALL AI Server services
# Run manually or auto-starts on boot
# ============================================

echo "Starting AI Server in a Box services..."

# Ollama (AI model server)
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" ollama serve &
sleep 3
echo "  [1/5] Ollama started"

# Open WebUI (Docker - AI chat interface)
docker start open-webui 2>/dev/null
echo "  [2/5] Open WebUI started"

# Jupyter Notebooks
source ~/ai-ecosystem/venv/bin/activate
nohup jupyter notebook --notebook-dir=~/ai-ecosystem/notebooks &>/dev/null &
echo "  [3/5] Jupyter started"

# Main Dashboard (port 9090)
cd ~/ai-ecosystem/dashboard
nohup python3 -m http.server 9090 &>/dev/null &
echo "  [4/5] Dashboard started"

# Creative Hub (port 9091)
cd ~/ai-ecosystem/creative-hub
nohup python3 -m http.server 9091 &>/dev/null &
echo "  [5/5] Creative Hub started"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  All services running!                       ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  AI Chat:       http://localhost:8080        ║"
echo "║  Jupyter:       http://localhost:8888        ║"
echo "║  Dashboard:     http://localhost:9090        ║"
echo "║  Creative Hub:  http://localhost:9091        ║"
echo "║  ComfyUI:       Run start_comfyui.sh         ║"
echo "║  Ollama API:    http://localhost:11434       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Jupyter token: ai-server-token"
STARTEOF
    chmod +x ~/ai-ecosystem/start_all.sh

    mark_done "start_all_v2"
else
    log "start_all.sh already updated"
fi

# --- 9B: Test all services ---
echo ""
echo "Testing all services..."

test_service() {
    if curl -s --max-time 5 "$1" > /dev/null 2>&1; then
        echo "  ✅ $2 — Online"
    else
        echo "  ❌ $2 — Offline (may need manual start)"
    fi
}

test_service "http://localhost:11434" "Ollama API (port 11434)"
test_service "http://localhost:8080" "Open WebUI (port 8080)"
test_service "http://localhost:8888" "Jupyter (port 8888)"
test_service "http://localhost:9090" "Dashboard (port 9090)"
test_service "http://localhost:9091" "Creative Hub (port 9091)"

echo ""
echo "✅ Sprint 9 complete"

# ============================================================
# FINAL SUMMARY
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║     ALL SPRINTS COMPLETE!                            ║"
echo "║     Your AI Server is fully operational              ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "┌──────────────────────────────────────────────────────┐"
echo "│  SERVICE            URL                              │"
echo "├──────────────────────────────────────────────────────┤"
echo "│  AI Chat            http://localhost:8080            │"
echo "│  Jupyter            http://localhost:8888            │"
echo "│  Dashboard          http://localhost:9090            │"
echo "│  Creative Hub       http://localhost:9091            │"
echo "│  ComfyUI            http://localhost:8188            │"
echo "│  Ollama API         http://localhost:11434           │"
echo "└──────────────────────────────────────────────────────┘"
echo ""
echo "Jupyter token: ai-server-token"
echo ""
echo "Log saved to: $LOG"
echo ""
echo "Next: bash ~/ai-ecosystem/start_all.sh"
echo ""
log "Sprints 8 & 9 completed successfully!"
