#!/usr/bin/env python3
"""
Product Research Agent
Uses Ollama (local) or Google Gemini (API) to research any topic.
Helps with market analysis, competitor research, and product ideation.
"""
import requests
import json
import sys
import os

OLLAMA_URL = "http://localhost:11434/api/generate"

def ask_ollama(prompt, model="gemma3:4b", stream=True):
    """Query local Ollama model"""
    try:
        response = requests.post(OLLAMA_URL, json={
            "model": model,
            "prompt": prompt,
            "stream": stream
        }, timeout=60)

        if stream:
            # Stream the response
            result = ""
            for line in response.iter_lines():
                if line:
                    data = json.loads(line)
                    result += data.get("response", "")
                    print(data.get("response", ""), end="", flush=True)
            print()
            return result
        else:
            return response.json().get("response", "No response")
    except requests.exceptions.ConnectionError:
        return "ERROR: Cannot connect to Ollama. Is it running? (http://localhost:11434)"
    except Exception as e:
        return f"ERROR: {str(e)}"

def research_product(topic, industry="general", depth="medium"):
    """Research a product topic"""

    depth_instructions = {
        "quick": "Provide a brief 2-3 paragraph overview.",
        "medium": "Provide a detailed analysis with 5-7 key points.",
        "deep": "Provide a comprehensive analysis with 10+ key points and specific examples."
    }

    prompt = f"""You are a senior product manager and market researcher specializing in {industry}.

Research and analyze the following topic in detail: {topic}

{depth_instructions.get(depth, depth_instructions['medium'])}

Include:
1. Market overview and size estimates
2. Key players and competitors
3. Current trends and innovations
4. Opportunities and gaps in the market
5. Potential challenges and risks
6. Target customer segments
7. Recommended next steps for building a product in this space

Be specific, data-driven where possible, and actionable."""

    print(f"\n🔍 Researching: {topic}")
    print(f"Industry: {industry} | Depth: {depth}\n")
    print("=" * 60)
    print()

    result = ask_ollama(prompt, stream=True)

    print()
    print("=" * 60)
    return result

def research_competitor(company_name, industry="general"):
    """Research a specific company and competitor"""
    prompt = f"""You are a competitive intelligence analyst.

Provide a detailed analysis of: {company_name}

Include:
1. Company overview and mission
2. Products and services
3. Market position and strengths
4. Weaknesses and gaps
5. Key customers
6. Pricing strategy
7. Innovation roadmap (if known)
8. Competitive advantages
9. Vulnerabilities

Be specific and factual."""

    print(f"\n📊 Competitor Analysis: {company_name}")
    print(f"Industry: {industry}\n")
    print("=" * 60)
    print()

    result = ask_ollama(prompt, stream=True)

    print()
    print("=" * 60)
    return result

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 product_research_agent.py 'topic to research'")
        print("  python3 product_research_agent.py 'topic' industry [quick|medium|deep]")
        print("\nExamples:")
        print("  python3 product_research_agent.py 'AI assistants for customer service'")
        print("  python3 product_research_agent.py 'wearable devices' healthcare deep")
        print("  python3 product_research_agent.py 'competitor:Apple' technology")
        sys.exit(1)

    topic = sys.argv[1]
    industry = sys.argv[2] if len(sys.argv) > 2 else "general"
    depth = sys.argv[3] if len(sys.argv) > 3 else "medium"

    # Handle competitor research
    if topic.startswith("competitor:"):
        company = topic.replace("competitor:", "").strip()
        research_competitor(company, industry)
    else:
        research_product(topic, industry, depth)
