# AI Server in a Box

Transform any idle Mac (or Linux PC) into a **24/7 AI server** — local AI models, web chat interface, coding agents, Jupyter notebooks, and more. One command. Zero cloud costs for local AI.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)

## What You Get

| Service | Port | Description |
|---------|------|-------------|
| Open WebUI | 8080 | ChatGPT-like browser interface for all your AI models |
| Jupyter Notebooks | 8888 | Browser-based coding & data analysis |
| Monitoring Dashboard | 9090 | Real-time health checks for all services |
| Creative Tools Hub | 9091 | Links to AI design & video tools |
| Ollama API | 11434 | REST API for AI model inference |
| Claude Code | CLI | Autonomous coding agent in Terminal |

## AI Models Installed (Local, Free, Private)

| Model | Size | Best For |
|-------|------|----------|
| **Gemma 3 4B** | 3.3 GB | Quick Q&A, summaries, fast replies |
| **Qwen 2.5 Coder 7B** | 4.7 GB | Code generation, HTML/CSS/JS, scripts |
| **DeepSeek Coder V2 16B** | 8.9 GB | Serious code — full apps, dashboards |
| **Phi-4 14B** | 9.1 GB | Deep research, analysis, reasoning |

All models run 100% locally. No data leaves your machine. No API costs.

### Upgrade Models

```bash
# Remove old models
ollama rm codellama:7b mistral:7b

# Pull the upgraded lineup
ollama pull qwen2.5-coder:7b
ollama pull deepseek-coder-v2:16b
ollama pull phi4:14b
```

## Requirements

- **Mac** (Intel or Apple Silicon) with 16GB+ RAM, or **Linux PC** with similar specs
- macOS 12+ or Ubuntu 20.04+
- 30GB free disk space (for models)
- Internet connection (for initial download only)

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/mayakub-byte/ai-server-in-a-box.git
cd ai-server-in-a-box
```

### 2. Run the master setup

```bash
bash scripts/master_setup.sh
```

That's it. Go grab a coffee — it takes about 45-60 minutes (mostly downloading AI models). When it's done, you'll see:

```
╔══════════════════════════════════════════════╗
║     SETUP COMPLETE!                          ║
╚══════════════════════════════════════════════╝

  AI Chat:       http://YOUR_IP:8080
  Jupyter:       http://YOUR_IP:8888
  Dashboard:     http://YOUR_IP:9090
  Ollama API:    http://YOUR_IP:11434
```

### 3. Optional: Add API keys for cloud AI

```bash
# Google Gemini (free tier available)
export GOOGLE_API_KEY="your-key-from-aistudio.google.com/apikey"

# Anthropic Claude Code (for autonomous coding)
export ANTHROPIC_API_KEY="your-key-from-console.anthropic.com"
```

### 4. Optional: Set up autonomous coding

```bash
bash scripts/setup_coding_agents.sh
```

## What Gets Installed

The setup runs in automated sprints:

| Sprint | What | Time |
|--------|------|------|
| 0 | Prerequisites (Homebrew, Python, Node, Docker) | ~5 min |
| 1 | Ollama + 4 AI models + Open WebUI | ~30 min |
| 2 | Google Gemini CLI + Python SDK | ~3 min |
| 3 | Python AI development environment (venv + packages) | ~10 min |
| 4 | AI Agents (research, data analysis, orchestrator) | ~2 min |
| 5 | Jupyter Notebook server | ~2 min |
| 6 | Monitoring dashboard | ~1 min |
| 7 | Auto-start on boot (LaunchAgents) | ~1 min |
| 8 | Creative tools hub + image generation | ~10 min |
| 9 | Integration testing + reference card | ~2 min |

**Safe to re-run**: Progress is tracked in `.setup_progress`. If interrupted, run again and it skips completed steps.

## 24/7 Server Setup

To make your machine an always-on AI server:

```bash
# Prevent sleep (macOS)
sudo pmset -a sleep 0 displaysleep 0 disksleep 0

# Set static IP (System Settings → Network → Wi-Fi → Details → TCP/IP → Manual)

# Install Tailscale for remote access from anywhere
# https://tailscale.com/download
```

## Access From Anywhere

| From | How |
|------|-----|
| Same network | Use machine's local IP |
| Remote | Install [Tailscale](https://tailscale.com) on server + your device |
| Phone | Tailscale app + open URLs in mobile browser |
| Laptop | VNC for remote desktop, or just use web URLs |

## Overnight Coding

Give your server coding tasks before bed:

```bash
# Create a task list
cat > tasks.txt << EOF
Add input validation to signup form
Write unit tests for the auth module
Fix the pagination bug in the products API
EOF

# Run overnight
bash scripts/overnight_code.sh ~/projects/your-repo tasks.txt

# Wake up to code on a new branch, review the diff
```

## AI Workflow Playbook

Use the right model at the right stage — free for exploration, paid only for production:

| Stage | Model | Cost | What Happens |
|-------|-------|------|--------------|
| 1. Idea | Gemma 3 4B | FREE | Validate the idea, get a go/no-go |
| 2. Research | Phi-4 14B | FREE | Market research, architecture, risks |
| 3. Prototype | DeepSeek Coder V2 | FREE | Generate working code skeleton |
| 4. Iterate | Local + Claude Code | MIX | Refine with local for small fixes, Claude for complex logic |
| 5. Build | Claude Code | PAID | Production-grade code with tests |
| 6. Go Live | Mix | MIX | Deploy, monitor with local LLMs |

```bash
# Start the workflow for any project
bash scripts/ai_workflow.sh my-project 1-idea
```

Every stage writes to a shared `CONTEXT.md` file. When you switch models, the next one reads the context and picks up where the last one left off. 70% of ideas die before Stage 4 — you've spent nothing to find out.

## Project Structure

```
ai-server-in-a-box/
├── scripts/
│   ├── master_setup.sh          # Main setup (Sprints 0-7)
│   ├── setup_sprint_8_9.sh      # Design & integration (Sprints 8-9)
│   ├── setup_coding_agents.sh   # Claude Code + GitHub CLI
│   ├── set_api_keys.sh          # Configure API keys
│   ├── overnight_code.sh        # Multi-task overnight agent
│   └── start_all.sh             # Start all services manually
├── agents/
│   ├── product_research_agent.py
│   ├── data_agent.py
│   └── orchestrator.py
├── dashboard/
│   └── index.html               # Monitoring dashboard
├── creative-hub/
│   └── index.html               # Creative tools portal
├── scripts/
│   └── ai_workflow.sh          # Idea-to-Live pipeline runner
├── playbook/
│   ├── AI_PLAYBOOK.md          # Complete workflow guide
│   └── CONTEXT_TEMPLATE.md     # Shared context template
├── LICENSE
└── README.md
```

## Hardware Tested On

- iMac 27" 5K (2020) — Intel i7 8-core, 16GB RAM, 1TB SSD
- Models run on CPU (no GPU required)
- Response time: 10-30 seconds per query (CPU inference)

## Contributing

PRs welcome! Ideas for improvement:

- [ ] Apple Silicon optimization (GPU inference via Metal)
- [ ] One-click installer (.pkg or .dmg)
- [ ] Web-based setup wizard
- [x] More model options (DeepSeek Coder V2, Qwen 2.5, Phi-4)
- [ ] Voice interface integration

## License

MIT License — use it however you want.

## Author

**Yakub Ali** — Product Builder

- LinkedIn: [Yakub Ali Mohammed](https://linkedin.com/in/yakubali)
- GitHub: [mayakub-byte](https://github.com/mayakub-byte)

---

*Built in one session. From dusty iMac to 24/7 AI server. If you have an old Mac sitting idle, it might be your next AI server.*
