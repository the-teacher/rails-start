# ActiveHarness — Setup Guide

## 1. Add the gem

Add the gem to your Gemfile:

```ruby
# Gemfile
gem "active_harness"
```

## 2. Install dependencies

```bash
bundle install
```

## 3. Run the install generator

```bash
rails generate active_harness:install
```

The generator creates:

**Directory structure** under `app/ai/`:

```
app/ai/
  agents/      # AI agent classes (+ example: SupportAgent, SupportGuardAgent)
  prompts/     # Prompt templates
  tribunals/   # Guard/moderation tribunals
  pipelines/   # Multi-step pipelines
  memory/      # Memory adapter instances
```

**Controller** `app/controllers/ai_support_controller.rb` with ready-to-use endpoints.

**Routes** added to `config/routes.rb`:

```
POST /ai/agent          — single agent call
POST /ai/agent_memory   — agent call with session memory
POST /ai/tribunal       — content moderation check
POST /ai/pipeline       — full pipeline run
GET  /ai/agent_stream   — streaming response (SSE)
```

## 4. Configure API keys

ActiveHarness reads provider keys from environment variables. Choose one of the options below.

**Option A — export in shell (quick test):**

```bash
export OPENROUTER_API_KEY=sk-or-v1-...
```

**Option B — `.env` file + `dotenv-rails` gem:**

```ruby
# Gemfile
gem "dotenv-rails"
```

```bash
bundle install
```

Create `.env` in Rails root:

```bash
# .env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GEMINI_API_KEY=...
GROQ_API_KEY=...
OPENROUTER_API_KEY=sk-or-v1-...
```

Add `.env` to `.gitignore`:

```bash
echo ".env" >> .gitignore
```

**Option C — Rails credentials:**

```bash
rails credentials:edit
```

```yaml
openrouter_api_key: sk-or-v1-...
```

Then expose it in e.g. `config/initializers/active_harness.rb`:

```ruby
ENV["OPENROUTER_API_KEY"] ||= Rails.application.credentials.openrouter_api_key
```

## 5. Try it

```bash
# Single agent call
curl -X POST http://localhost:3000/ai/agent \
  -H "Content-Type: application/json" \
  -d '{"input": "Hello!"}'

# {"output":"Hi, how can I assist you today?","model":"mistralai/mistral-nemo","time":2.862}

# With memory (keeps context across requests)
curl -X POST http://localhost:3000/ai/agent_memory \
  -H "Content-Type: application/json" \
  -d '{"input": "Hello!", "session_id": "user_42"}'

# File: `storage/ai/memory/user_42.json` is created with the conversation history, and the agent can reference it in future calls.
```
