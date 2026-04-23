# AI Server in a Box - Setup Files Summary

## Overview
This repository contains clean, open-source setup scripts for running a complete AI development server on any macOS machine. No API keys or project-specific references are hardcoded.

## File Structure

```
ai-server-in-a-box/
├── README.md                          # Main documentation (created separately)
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
├── SETUP_SUMMARY.md                   # This file
│
├── scripts/
│   ├── master_setup.sh                # Main setup (Sprints 0-7)
│   ├── setup_sprint_8_9.sh            # Design & creative tools (Sprints 8-9)
│   ├── setup_coding_agents.sh         # Claude Code + coding tools
│   ├── set_api_keys.sh                # Configure API keys interactively
│   ├── start_all.sh                   # Start all services
│   └── overnight_code.sh              # Code review agent
│
└── agents/
    ├── product_research_agent.py      # Product research using local AI
    ├── data_agent.py                  # SQL generation and data analysis
    └── orchestrator.py                # Multi-agent router
```

## Scripts Overview

### 1. master_setup.sh (Sprints 0-7)
**Purpose:** Complete initial setup of AI server
**What it does:**
- Installs Homebrew, Python, Node.js, Docker
- Sets up Ollama with AI models (Gemma, Llama, CodeLlama, Mistral)
- Installs Open WebUI (Docker)
- Sets up Python AI development environment
- Creates AI agents directory
- Installs and configures Jupyter Notebook server
- Creates monitoring dashboard
- Sets up auto-start on boot

**Usage:**
```bash
bash scripts/master_setup.sh
```

**Key Changes from Original:**
- Replaces hardcoded `/Volumes/CoWork - Conenct iMac` with `SCRIPT_DIR` variable
- Uses `ipconfig getifaddr en0` to auto-detect server IP (not hardcoded 192.168.29.191)
- Removes "Yakub Ali - April 2026" author references
- All API keys replaced with `YOUR_KEY_HERE` placeholders
- No project-specific database references
- Works on any Mac, not just this iMac

### 2. setup_sprint_8_9.sh (Sprints 8-9)
**Purpose:** Set up design, creative, and video tools
**What it does:**
- Installs ComfyUI (Stable Diffusion UI)
- Sets up image generation with local AI
- Creates Creative Tools Hub (port 9091)
- Updates start_all.sh with new services
- Tests all services
- Integrates everything

**Usage:**
```bash
bash scripts/setup_sprint_8_9.sh
```

### 3. setup_coding_agents.sh
**Purpose:** Set up Claude Code and coding automation
**What it does:**
- Installs GitHub CLI
- Configures Git
- Installs Claude Code (npm)
- Creates helper scripts for running AI-powered code tasks
- Sets up overnight code review agent
- Creates repo cloning helper

**Usage:**
```bash
bash scripts/setup_coding_agents.sh
```

**Helper Scripts Created:**
- `run_claude_task.sh` - Run Claude Code on a specific task
- `overnight_code.sh` - Run multiple tasks while you sleep
- `clone_and_code.sh` - Clone repo and start coding

### 4. set_api_keys.sh
**Purpose:** Interactively configure API keys
**What it does:**
- Prompts for Google API key (Gemini)
- Prompts for Anthropic API key (Claude)
- Saves to ~/.zshrc and ~/.bash_profile
- Sets via launchctl for background services

**Usage:**
```bash
bash scripts/set_api_keys.sh
```

### 5. start_all.sh
**Purpose:** Start all AI services at once
**What it does:**
- Starts Ollama on port 11434
- Starts Open WebUI on port 8080
- Starts Jupyter on port 8888
- Starts main dashboard on port 9090
- Starts creative hub on port 9091

**Usage:**
```bash
bash scripts/start_all.sh
```

**Services:**
- AI Chat: http://localhost:8080
- Jupyter: http://localhost:8888 (token: ai-server-token)
- Dashboard: http://localhost:9090
- Creative Hub: http://localhost:9091
- Ollama API: http://localhost:11434

### 6. overnight_code.sh
**Purpose:** Automated code review of all GitHub repos
**What it does:**
- Fetches all repos from GitHub
- Clones or updates each repo
- Runs Claude Code review on each
- Generates detailed analysis reports
- Creates summary report

**Usage:**
```bash
bash scripts/overnight_code.sh
```

**Output:**
- Reports in `code_reviews_YYYYMMDD/` directory
- Individual reviews for each repo
- Summary.md overview

## Python Agents

### product_research_agent.py
**Purpose:** Research products, markets, and competitors using local AI
**Usage:**
```bash
python3 agents/product_research_agent.py "AI assistants for customer service"
python3 agents/product_research_agent.py "AI trends" healthcare deep
python3 agents/product_research_agent.py "competitor:Apple" technology
```

**Features:**
- Market research
- Competitor analysis
- Trend analysis
- 3 depth levels: quick, medium, deep
- Stream response for real-time output

### data_agent.py
**Purpose:** Generate SQL queries and data analysis plans from natural language
**Usage:**
```bash
python3 agents/data_agent.py "Show revenue by product category"
python3 agents/data_agent.py "Top 10 customers by value" snowflake
python3 agents/data_agent.py "plan:Analyze customer churn" postgresql
```

**Features:**
- SQL query generation (SELECT only)
- Supports multiple dialects (PostgreSQL, Snowflake, etc.)
- Analysis planning mode
- READ-ONLY (never generates data modification queries)
- Stream response

### orchestrator.py
**Purpose:** Route queries to the right agent based on intent
**Usage:**
```bash
python3 agents/orchestrator.py "Research AI trends"
python3 agents/orchestrator.py "Get revenue by month"
python3 agents/orchestrator.py  # Interactive mode
```

**Features:**
- Intent classification
- Routes to: research, data, code, design, or general agents
- Interactive mode
- Real-time streaming

## Key Differences from Original Scripts

### Security
- No hardcoded API keys (uses `YOUR_KEY_HERE` placeholders)
- set_api_keys.sh for secure configuration
- All credentials stored in ~/.zshrc (user controls)

### Portability
- Dynamic `SCRIPT_DIR` variable for relative paths
- Auto-detects server IP with `ipconfig getifaddr en0`
- Works on any Mac (not just this specific iMac)
- No hardcoded usernames or email addresses

### Privacy
- Removed project-specific references:
  - No fpi-db, fwt-db, KWD, health tech, retail, ecom references
  - No internal database connections
  - No company-specific configurations

### Cleanliness
- Removed internal comments and debug notes
- Clean, professional documentation
- Open-source ready
- MIT licensed

## Installation Steps

### 1. Initial Setup (Sprints 0-7)
```bash
bash scripts/master_setup.sh
```
Takes 30-60 minutes depending on model downloads.

### 2. Add Design Tools (Sprints 8-9)
```bash
bash scripts/setup_sprint_8_9.sh
```
Optional but recommended.

### 3. Set Up Coding (Optional)
```bash
bash scripts/setup_coding_agents.sh
gh auth login  # Authenticate GitHub
```

### 4. Configure API Keys
```bash
bash scripts/set_api_keys.sh
```

### 5. Start Everything
```bash
bash scripts/start_all.sh
```

## Services

### Local Services (Always Running)
- **Ollama** (port 11434) - Local AI models
- **Open WebUI** (port 8080) - Web chat interface
- **Jupyter** (port 8888) - Notebook environment
- **Dashboard** (port 9090) - Service monitoring
- **Creative Hub** (port 9091) - Design tools

### Optional Services
- **ComfyUI** (port 8188) - Image generation
- **Claude Code** - AI-powered coding

## Environment Variables

After running `set_api_keys.sh`:
```bash
export GOOGLE_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
```

These are saved to:
- ~/.zshrc (macOS default shell)
- ~/.bash_profile (for Bash)
- launchctl (for background services)

## Troubleshooting

### Docker not starting
```bash
open /Applications/Docker.app
# Wait for Docker to start, then retry
```

### Ollama not responding
```bash
# Check if running
ps aux | grep ollama

# Start manually
OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" ollama serve &
```

### Port already in use
Find and kill the process:
```bash
lsof -i :8080  # Find process on port 8080
kill -9 <PID>  # Kill it
```

### API key issues
```bash
# Verify keys are set
echo $GOOGLE_API_KEY
echo $ANTHROPIC_API_KEY

# Re-configure
bash scripts/set_api_keys.sh
source ~/.zshrc
```

## Directory Structure After Setup

```bash
~/ai-ecosystem/
├── venv/                    # Python virtual environment
├── activate.sh              # Quick activation script
├── agents/                  # AI agents
│   ├── product_research_agent.py
│   ├── data_agent.py
│   └── orchestrator.py
├── design/                  # Design tools
│   ├── ComfyUI/
│   ├── start_comfyui.sh
│   └── generate_image_prompt.py
├── notebooks/               # Jupyter notebooks
│   └── welcome.py
├── dashboard/               # Monitoring dashboard
│   └── index.html
├── creative-hub/            # Creative tools hub
│   └── index.html
├── start_all.sh             # Start all services
├── run_claude_task.sh       # Claude Code runner
├── overnight_code.sh        # Code review agent
└── clone_and_code.sh        # Clone and code helper
```

## License

MIT License - See LICENSE file

## Support

For issues:
1. Check troubleshooting section
2. Review script logs: `setup_log.txt`
3. Check service status: http://localhost:9090

## Next Steps

1. Read the README.md for detailed usage
2. Start all services: `bash scripts/start_all.sh`
3. Open dashboard: http://localhost:9090
4. Try the agents:
   - Research: `python3 agents/product_research_agent.py "AI trends"`
   - Data: `python3 agents/data_agent.py "Show top products"`
   - Coding: `bash scripts/setup_coding_agents.sh`
