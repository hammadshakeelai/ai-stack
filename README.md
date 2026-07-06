# AI Stack — a private, self-healing AI assistant that costs $0/month

A self-hosted setup that gives you a ChatGPT-style web UI **and** a terminal AI agent
with **persistent memory**, running on your own machine, powered by **free API tiers**
with **automatic failover** — if one provider rate-limits you, the next one answers.
Add local models (LM Studio / Ollama) and your chats never leave your laptop at all.

```
            ┌─────────────────────────────────────────────┐
 Odysseus ─▶│  LiteLLM gateway   http://localhost:4000/v1 │─▶ Groq        (primary)
 OpenClaw ─▶│  model "auto"  →   Groq → Gemini → OpenRouter│─▶ Gemini      (fallback 1)
 any app  ─▶│                                             │─▶ OpenRouter  (fallback 2)
            └─────────────────────────────────────────────┘
```

One OpenAI-compatible endpoint. Every app you own points at it. The fallback chain is
handled once, in the gateway — not per app.

## What you get

| Part | What | URL / command |
|------|------|----------------|
| **Gateway** | [LiteLLM](https://github.com/BerriAI/litellm) proxy, 3-provider fallback | `http://localhost:4000/v1` (model `auto`) |
| **Odysseus** | Private ChatGPT-style web UI with agent mode + persistent memory | `http://localhost:7000` |
| **OpenClaw** | AI agent for your terminal / messaging | `openclaw` |
| **Local models** | LM Studio / Ollama models auto-discovered by Odysseus | fully offline, 100% private |

## A note on privacy (the honest version)

- **Local models** (LM Studio / Ollama): nothing ever leaves your machine. This is the
  truly private path — use it for anything sensitive.
- **Groq**: states it does not train on API data.
- **OpenRouter**: has an account-level data policy setting — turn OFF "free endpoints
  that may train on inputs" if you care (Settings → Privacy).
- **Google Gemini free tier**: Google MAY use free-tier prompts to improve its models.
  Know that before you send anything personal through it.

The point of this stack is that **you choose per conversation**: local model for private
stuff, free APIs for everything else — all in one UI.

## Setup (Windows; the ideas port anywhere)

### 0. Prerequisites

- Python 3.11+ and Git
- (optional) [LM Studio](https://lmstudio.ai) for local models
- (optional) Node.js for OpenClaw

### 1. Get your free API keys (5 minutes)

| Provider | Where | Free tier |
|---|---|---|
| Groq | https://console.groq.com/keys | fast Llama 3.3 70B, generous limits |
| Google Gemini | https://aistudio.google.com/apikey | gemini-2.5-flash |
| OpenRouter | https://openrouter.ai/keys | `:free` models (~50 req/day backstop) |

### 2. Gateway (LiteLLM)

```powershell
git clone https://github.com/hammadshakeelai/ai-stack
cd ai-stack\gateway
python -m venv venv
venv\Scripts\pip install "litellm[proxy]"
copy .env.example .env      # then edit .env and paste your keys
```

The fallback chain lives in [`gateway/config.yaml`](gateway/config.yaml):
`auto` = Groq first; if it fails or rate-limits → Gemini → OpenRouter, automatically.
Free model slugs change over time — if a model 404s, update the `model:` lines.

Test it:

```powershell
.\start-gateway.ps1
curl http://localhost:4000/v1/chat/completions -H "Authorization: Bearer <your LITELLM_MASTER_KEY>" -H "Content-Type: application/json" -d "{\"model\":\"auto\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}"
```

### 3. Odysseus (the web UI)

[Odysseus](https://github.com/pewdiepie-archdaemon/odysseus) is an open-source,
self-hosted chat UI with an agent mode (tools, workspaces) and persistent memory.

```powershell
cd ..    # back to ai-stack\
git clone https://github.com/pewdiepie-archdaemon/odysseus
cd odysseus
python -m venv venv
venv\Scripts\pip install -r requirements.txt
copy ..\extras\seed_gateway_endpoint.py .
venv\Scripts\python seed_gateway_endpoint.py   # registers the gateway as a model endpoint
```

### 4. Start everything

```powershell
powershell -ExecutionPolicy Bypass -File .\start-stack.ps1
```

Opens http://localhost:7000 — log in, pick model `auto`, chat. Kill both servers with
`stop-stack.ps1`. For a Win+R launcher, add `bin\` to your PATH (`ody` starts the stack).

### 5. Local models (the 100%-private lane)

Run LM Studio (or Ollama) and load any model — Odysseus scans common local serve ports
(LM Studio's 1234, Ollama's 11434) and lists your local models next to the API ones.

### 6. OpenClaw (optional — AI agent in the terminal)

```powershell
npm install -g openclaw
```

Merge [`extras/openclaw-patch.json5`](extras/openclaw-patch.json5) into
`~/.openclaw/openclaw.json` (set `apiKey` to your `LITELLM_MASTER_KEY`) — OpenClaw then
uses the same gateway and the same fallback chain. The wrappers in `bin\` make a bare
`openclaw` command open the TUI with the gateway auto-started.

## Security checklist

- `gateway/.env` is gitignored — **never** commit real keys, and rotate any key you
  ever pasted somewhere in plaintext.
- Keep ports 4000 / 7000 bound to localhost (the scripts already do).
- Change the Odysseus admin password after setup (Settings).

## Files

- `gateway/config.yaml` — providers + fallback chain (edit model slugs here)
- `gateway/.env.example` — key template (copy to `.env`)
- `gateway/start-gateway.ps1` — runs the proxy on :4000
- `start-stack.ps1` / `stop-stack.ps1` / `start-odysseus.ps1` — start/stop the stack
- `bin/` — `ody` launcher + `openclaw` TUI wrapper
- `extras/` — Odysseus endpoint seeder, OpenClaw config patch
- `gen_icon.py` / `odysseus.ico` — desktop icon

## License

MIT — see [LICENSE](LICENSE).
