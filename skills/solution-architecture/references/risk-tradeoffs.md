# Risk and trade-off register (lite)

Load when evaluating alternatives or building the risk register (SCALER step 5).

## Trade-off matrix (per major choice)

| Dimension | Option A | Option B |
|-----------|----------|----------|
| Benefits | | |
| Risks | | |
| Reliability | | |
| Security | | |
| Cost | | |
| Portability / operability | | |
| Best fit | | |

Prefer the simplest architecture that meets the evaluated workload. Add complexity only when measurable improvements justify cost, latency, failure modes, and ops burden.

## Risk statement format

```text
Because [condition], [undesired event] may occur, resulting in [impact].
```

## Risk register columns

| Risk | L | I | Prevent | Detect | Respond | Owner | Residual |
|------|---|---|---------|--------|---------|-------|----------|
| | | | | | | | |

L = likelihood, I = impact (use the org’s scale). Document residual risk after controls.

## Control standard

A single guardrail is not a complete mitigation. Prefer preventive + detective + response controls, each with an owner and evidence source.

## Side project vs enterprise depth

| Practice | Side project | Enterprise |
|----------|--------------|------------|
| Risk register | Top 5 risks | Owned register + residual-risk acceptance |
| ADRs | Major irreversible choices | Significant platform/governance decisions |
| Threat model | Lightweight abuse cases | Formal review when required |
