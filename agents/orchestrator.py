#!/usr/bin/env python3
"""
Multi-Agent Orchestrator
Routes requests to the right agent based on intent detection.
Handles: research, data analysis, coding help, design, and general questions.
"""
import requests
import json
import subprocess
import sys
import os

OLLAMA_URL = "http://localhost:11434/api/generate"
AGENTS_DIR = os.path.dirname(os.path.abspath(__file__))

def ask_ollama(prompt, model="gemma3:4b", stream=False):
    """Query local Ollama model"""
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": model,
            "prompt": prompt,
            "stream": stream
        }, timeout=30)

        if not stream:
            return response.json().get("response", "No response").strip()
        else:
            result = ""
            for line in response.iter_lines():
                if line:
                    data = json.loads(line)
                    result += data.get("response", "")
            return result.strip()
    except Exception as e:
        return f"ERROR: {str(e)}"

def classify_intent(query):
    """Classify user intent to route to correct agent"""
    prompt = f"""Classify this request into ONE category:
- RESEARCH: product research, market analysis, competitor analysis, trends, ideation
- DATA: database queries, data analysis, SQL, reports, metrics, analytics
- CODE: coding help, debugging, code generation, programming, development
- DESIGN: UI design, wireframes, visual design, UX, architecture diagrams
- GENERAL: general questions, conversation, explanations, info

Request: {query}

Reply with ONLY the category name, nothing else."""

    result = ask_ollama(prompt, stream=False)

    # Extract just the category name
    category = result.upper().strip()

    # Validate and clean up
    valid_categories = ["RESEARCH", "DATA", "CODE", "DESIGN", "GENERAL"]
    for cat in valid_categories:
        if cat in category:
            return cat

    return "GENERAL"

def run_agent(agent_name, query):
    """Run a specific agent script"""
    try:
        agent_path = os.path.join(AGENTS_DIR, f"{agent_name}.py")

        if not os.path.exists(agent_path):
            return f"ERROR: Agent {agent_name}.py not found"

        # Run the agent
        result = subprocess.run(
            [sys.executable, agent_path, query],
            capture_output=False,  # Show output directly
            text=True,
            cwd=AGENTS_DIR
        )
        return ""  # Output was printed directly
    except Exception as e:
        return f"ERROR running {agent_name}: {str(e)}"

def handle_request(query):
    """Route request to appropriate agent based on intent"""
    print()
    print("🎯 Analyzing request...")

    intent = classify_intent(query)

    print(f"📍 Intent: {intent}")
    print()

    if intent == "RESEARCH":
        print("→ Routing to Product Research Agent...\n")
        print("=" * 60)
        run_agent("product_research_agent", query)
        print("=" * 60)

    elif intent == "DATA":
        print("→ Routing to Data Analysis Agent...\n")
        print("=" * 60)
        run_agent("data_agent", query)
        print("=" * 60)

    elif intent == "CODE":
        print("→ For coding help, use Claude Code:")
        print("   cd /path/to/repo && claude")
        print("   OR")
        print("   bash ~/ai-ecosystem/run_claude_task.sh /path/to/repo 'your task'")
        print()

    elif intent == "DESIGN":
        print("→ For design work, use:")
        print("   - Google AI Studio: https://aistudio.google.com")
        print("   - ComfyUI for images: bash ~/ai-ecosystem/design/start_comfyui.sh")
        print("   - Creative Hub: http://localhost:9091")
        print()

    else:  # GENERAL
        print("→ Using general AI...\n")
        prompt = f"""Answer this question helpfully and concisely:

{query}"""

        response = ask_ollama(prompt, stream=False)
        print(response)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("╔════════════════════════════════════════════════╗")
        print("║  Multi-Agent Orchestrator                      ║")
        print("║  AI Server in a Box                            ║")
        print("╚════════════════════════════════════════════════╝")
        print()
        print("Usage:")
        print("  python3 orchestrator.py 'your question or task'")
        print()
        print("Examples:")
        print("  python3 orchestrator.py 'Research AI trends in 2026'")
        print("  python3 orchestrator.py 'Show total revenue by category'")
        print("  python3 orchestrator.py 'Help me understand OAuth'")
        print("  python3 orchestrator.py 'Design a login form for mobile'")
        print()
        print("Or run interactively:")
        print("  python3 orchestrator.py")
        print()

        # Interactive mode
        while True:
            try:
                query = input("Ask anything: ").strip()
                if query.lower() in ['exit', 'quit', 'q']:
                    print("Goodbye!")
                    break
                if query:
                    handle_request(query)
                    print()
            except KeyboardInterrupt:
                print("\nGoodbye!")
                break
            except Exception as e:
                print(f"ERROR: {str(e)}")
    else:
        query = " ".join(sys.argv[1:])
        handle_request(query)
