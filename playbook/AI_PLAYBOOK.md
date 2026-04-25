# AI Product Playbook — Idea to Live
**Author:** Yakub Ali | **Created:** April 23, 2026

> Spend less, get the best results. Use free local LLMs for exploration, paid tools only for production.

---

## The Philosophy

70% of ideas die before Stage 4. By using free local LLMs for Stages 1-3, you validate fast without spending a dirham. Only the survivors get the paid treatment.

**Cost breakdown:**
- Stage 1 (Idea): FREE — local Gemma/Mistral
- Stage 2 (Research): FREE — local Llama 3.1 + Gemini free tier
- Stage 3 (Prototype): FREE — local CodeLlama
- Stage 4 (Iterate): MIX — local for small fixes, Claude Code for complex logic
- Stage 5 (Build): PAID — Claude Code for production-grade output
- Stage 6 (Go Live): MIX — local for monitoring, Claude Code for hotfixes

---

## The Golden Rule: CONTEXT.md

Every project has one file: `CONTEXT.md`. Every AI tool reads it first, appends its output at the end. This is how Gemma's research flows into Claude Code's build — without you re-explaining anything.

**Start every prompt with:** "Read CONTEXT.md first, then..."

---

## Stage 1: IDEA (5-15 minutes, FREE)

**When:** You have a raw thought, a problem you noticed, or an opportunity.

**Tool:** Gemma 3 4B (fastest, good enough for brainstorming)

**Command:**
```bash
bash ai_workflow.sh my-project-name 1-idea
```

**What to tell the LLM:**
- "I noticed [problem]. Is there a product opportunity here?"
- "Who would pay for a solution to [X]?"
- "What's the simplest version of this I could build in a weekend?"

**Output:** Fill in Stage 1 of CONTEXT.md — problem, user, solution, validation.

**Decision gate:** Is this worth 30 more minutes of research? If no, kill it. Cost so far: $0.

---

## Stage 2: RESEARCH (30-60 minutes, FREE)

**When:** Idea survived Stage 1. You want to understand the market and technical path.

**Tool:** Llama 3.1 8B (strongest reasoning) + Gemini CLI (web-connected)

**Command:**
```bash
bash ai_workflow.sh my-project-name 2-research
```

**What to research:**
- Market size and trends (use Gemini for web data)
- Competitors — who else does this, what are they missing?
- Tech stack decision — what to build with and why
- Architecture sketch — how the pieces fit together
- Risks — what could kill this project

**For web-connected research:**
```bash
gemini "Search for competitors in [space]. What are the top 5 tools, their pricing, and user complaints?"
```

**Output:** Append findings to Stage 2 of CONTEXT.md.

**Decision gate:** Go / Pivot / Kill. Cost so far: $0.

---

## Stage 3: PROTOTYPE (2-4 hours, FREE)

**When:** Research says GO. Time to build the ugly first version.

**Tool:** CodeLlama 7B (code specialist)

**Command:**
```bash
bash ai_workflow.sh my-project-name 3-prototype
```

**What to build:**
- The ONE core feature, nothing else
- No auth, no payments, no polish
- Just enough to demo the concept
- Hardcode everything, use SQLite, skip the cloud

**Prompt pattern:**
```
ollama run codellama:7b "Build a [Flask/Express] app that does [one thing].
Requirements: [list 3-5 bullet points].
Keep it under 200 lines. Single file if possible."
```

**Test it:** Run locally on iMac. Show someone. Get a reaction.

**Output:** Working code + learnings in Stage 3 of CONTEXT.md.

**Decision gate:** Did it feel right when you used it? If no, pivot or kill. Cost so far: $0.

---

## Stage 4: ITERATE (Days/Weeks, MIX)

**When:** Prototype works. Now make it good.

**Tools:**
- CodeLlama (FREE) for: CSS fixes, simple refactors, adding a field, tweaking copy
- Claude Code (PAID) for: auth flows, payment integration, complex business logic, API design

**Command:**
```bash
bash ai_workflow.sh my-project-name 4-iterate
```

**The handoff pattern:**
```bash
# Small fix (free)
ollama run codellama:7b "Read this code and fix the date formatting bug: [paste code]"

# Complex work (paid — Claude Code)
cd ~/projects/my-project-name
claude "Read CONTEXT.md first. Then add user authentication with JWT tokens, password hashing, and rate limiting."
```

**Key rule:** Every Claude Code session starts with "Read CONTEXT.md first." This is how it inherits everything the local LLMs discovered.

**Output:** Refined app + iteration notes in Stage 4 of CONTEXT.md.

---

## Stage 5: BUILD (1-3 days, PAID)

**When:** Features work. Time to harden for real users.

**Tool:** Claude Code (this is where you invest)

**Command:**
```bash
bash ai_workflow.sh my-project-name 5-build
```

**What Claude Code does here:**
- Comprehensive error handling
- Unit tests (80%+ coverage)
- Input validation and security hardening
- Logging and monitoring
- API documentation
- Dockerfile + deployment config
- Performance optimization

**Overnight build pattern:**
```bash
cd ~/projects/my-project-name
claude "Read CONTEXT.md. This project is moving to production. Do a full hardening pass:
1. Add error handling to every endpoint
2. Write unit tests for all business logic
3. Add input validation
4. Set up structured logging
5. Create a Dockerfile
6. Update README with setup instructions
Work on a new branch called 'production-hardening'."
```

Run this before bed. Wake up to production-ready code.

**Output:** Production code + test results in Stage 5 of CONTEXT.md.

---

## Stage 6: GO LIVE (Ongoing, MIX)

**When:** Code is hardened. Ship it.

**Tools:**
- Local LLMs (FREE) for: log analysis, monitoring alerts, user feedback processing
- Claude Code (PAID) for: critical hotfixes, scaling issues

**Deploy options:**
- Railway, Render, Fly.io — for quick deploys
- AWS/GCP — for serious scale
- Your iMac — for internal tools or demos

**Post-launch monitoring (free):**
```bash
# Analyze logs with local LLM
ollama run gemma3:4b "Here are today's error logs. Summarize the issues and prioritize fixes: [paste logs]"

# Process user feedback
ollama run mistral:7b "Here's user feedback from today. Group by theme and suggest product improvements: [paste feedback]"
```

---

## Daily Routine

**Morning (15 min, FREE):**
```bash
# Check what overnight agents produced
ls ~/projects/*/CONTEXT.md
# Review any Claude Code overnight work
cd ~/projects/active-project && git log --oneline -5
```

**During the day (as needed, MIX):**
- Quick questions → Gemma (free)
- Writing → Mistral (free)
- Code fixes → CodeLlama (free)
- Complex features → Claude Code (paid)

**Before bed (5 min, PAID):**
```bash
# Give Claude Code overnight tasks
cd ~/projects/active-project
claude "Read CONTEXT.md. Tonight's tasks: [list 3-5 tasks]. Work on branch 'overnight-$(date +%m%d)'."
```

---

## Prompt Starter Pack

### For every tool, start with:
```
Read CONTEXT.md first for full project history. Then...
```

### Idea validation (Gemma):
```
I have an idea for [X]. The user is [Y]. The problem is [Z].
Poke holes in this. What am I missing? Is this worth building?
```

### Technical architecture (Llama 3.1):
```
Based on CONTEXT.md, design the system architecture.
Consider: scalability, cost, speed to build, maintenance burden.
Give me 2 options with trade-offs.
```

### Code generation (CodeLlama):
```
Build a [component] that does [function].
Tech: [stack]. Keep it under [N] lines.
Include: error handling, input validation, comments.
```

### Production review (Claude Code):
```
Read CONTEXT.md. Review all code in this repo.
Score: security, tests, error handling, performance (1-10 each).
Then fix the top 5 issues. Work on a new branch.
```

### Writing and comms (Mistral):
```
Write a [email/post/doc] about [topic].
Audience: [who]. Tone: [professional/casual/technical].
Keep it under [N] words.
```

---

## Tool-Cost Matrix

| Task Type | Tool | Cost | Speed |
|-----------|------|------|-------|
| Brainstorming | Gemma 3 4B | FREE | ~10 sec |
| Market research | Llama 3.1 8B | FREE | ~20 sec |
| Web research | Gemini CLI | FREE (quota) | ~3 sec |
| Code generation | CodeLlama 7B | FREE | ~15 sec |
| Writing/emails | Mistral 7B | FREE | ~15 sec |
| Complex code | Claude Code | ~$0.05-0.50/task | ~2 min |
| Code review | Claude Code | ~$0.10-0.30/task | ~3 min |
| Production build | Claude Code | ~$1-5/session | ~10 min |
| Overnight coding | Claude Code | ~$2-10/night | hours |

**Monthly estimate with this workflow:** $30-80 (vs $200+ if everything was cloud)

---

## Quick Start

1. SSH into your iMac: `ssh admin@100.70.72.75`
2. Start a new project: `bash "/Volumes/CoWork - Conenct iMac/ai_workflow.sh" my-new-idea 1-idea`
3. Follow the stages. Each one feeds the next via CONTEXT.md.
4. Use the decision gates. Kill early, kill free.

---

*The best product builders don't use the most expensive tools. They use the right tool at the right time.*
