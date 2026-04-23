#!/usr/bin/env python3
"""
Data Analysis Agent
General-purpose SQL query generator using local AI.
Generates SELECT queries from natural language descriptions.
READ-ONLY - only generates SELECT statements for data analysis.
"""
import requests
import json
import sys

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

def generate_sql(question, dialect="postgresql"):
    """Generate a READ-ONLY SQL query from natural language"""

    prompt = f"""You are an expert SQL analyst. Generate a {dialect} SELECT query to answer this question:

Question: {question}

CRITICAL RULES:
- ONLY use SELECT statements
- NEVER use INSERT, UPDATE, DELETE, DROP, ALTER, CREATE, TRUNCATE, or any data modification statements
- Use CTEs (WITH clauses) for complex queries
- Follow best practices for {dialect}
- Include meaningful aliases for columns
- Add helpful comments if the query is complex

Return ONLY the SQL query, nothing else. No markdown formatting, no explanation.

Example output format (no backticks):
SELECT customer_id, COUNT(*) as order_count, SUM(total) as total_spent
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY customer_id
ORDER BY total_spent DESC;"""

    print(f"\n📊 Generating SQL Query")
    print(f"Dialect: {dialect}")
    print(f"Question: {question}\n")
    print("=" * 60)
    print()

    result = ask_ollama(prompt, stream=True)

    print()
    print("=" * 60)
    print("\nUse this query on your database:")
    print("  psql -d your_database -c \"[PASTE QUERY HERE]\"")
    print("  OR")
    print("  sqlalchemy: session.execute(text('[PASTE QUERY HERE]'))")

    return result

def analyze_data(question):
    """Generate analysis steps for a data question"""

    prompt = f"""You are a data analyst. Given this question about data:

{question}

Provide:
1. What data is needed?
2. Key SQL query approach (without the actual SQL)
3. Expected columns and their meaning
4. Potential data quality issues to watch for
5. How to visualize the results
6. Key insights to look for"""

    print(f"\n📈 Data Analysis Plan")
    print(f"Question: {question}\n")
    print("=" * 60)
    print()

    result = ask_ollama(prompt, stream=True)

    print()
    print("=" * 60)
    print("\nNext: Use 'generate_sql' to create the actual query")
    return result

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 data_agent.py 'SQL question or data question'")
        print("  python3 data_agent.py 'question' dialect")
        print("\nExamples:")
        print("  python3 data_agent.py 'Show total revenue by product category'")
        print("  python3 data_agent.py 'How many customers made purchases in Q4?' postgresql")
        print("  python3 data_agent.py 'Analyze:What are our top 10 customers by revenue' snowflake")
        print("  python3 data_agent.py 'Plan:What data do we need to understand churn?' postgresql")
        sys.exit(1)

    question = sys.argv[1]
    dialect = sys.argv[2] if len(sys.argv) > 2 else "postgresql"

    # Check for special keywords
    if question.startswith("plan:") or question.startswith("analyze:"):
        # Analysis planning mode
        actual_question = question.split(":", 1)[1].strip()
        analyze_data(actual_question)
    else:
        # SQL generation mode
        generate_sql(question, dialect)
