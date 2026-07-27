# AI / agentic extensions

Load only when the system includes agents, models, retrieval, tool-calling, or generative AI.

## Extra view: AI lifecycle and governance

Show:

- Approved use case and risk classification
- Prompt, policy, model, tool, and knowledge versions
- Evaluation datasets and release thresholds
- Deployment approval and rollback controls
- Production quality, safety, latency, and cost monitoring
- User feedback, incident response, continuous improvement

## Agent design rule

Start with the simplest architecture that meets the evaluated workload. Add agentic complexity only when measurable improvements justify cost, latency, failure modes, and operational burden.

Prefer authorization **before** routing to agents/tools/knowledge.

## AI-specific risks to examine

- Prompt injection and tool/retrieval context manipulation
- Sensitive-information disclosure and improper data handling
- Supply-chain risk in models, packages, prompts, plugins, tools, data
- Data/knowledge poisoning or stale/unapproved sources
- Improper output handling and downstream execution of model content
- Excessive agency, permissions, autonomy, or irreversible action scope
- Vector/embedding access-control gaps and cross-tenant retrieval
- Misinformation, unsupported claims, bias, inaccessible output
- Unbounded consumption, loops, denial of service, runaway cost

## Data classification worksheet (AI)

| Field | Required answer |
|-------|-----------------|
| Source and owner | |
| Classification | |
| Permitted users / services / agents | |
| Permitted AI use (index, embed, prompt, memory) | |
| Retention (raw, embeddings, prompts, responses, logs) | |
| Protection (encrypt, redact, isolate, keys) | |
| Logging prohibitions | |

## Official AI sources

See `official-sources.md` (NIST AI RMF, OWASP LLM Top 10, Anthropic/OpenAI agent guides, AWS GenAI Lens).
