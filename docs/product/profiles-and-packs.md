# Profiles and packs — team skill contract model

How ADSK organizes adopter UX so teams get a **versioned workflow contract**, not a second skills marketplace.

**Eng-lead pitch:** [for-eng-leads.md](for-eng-leads.md)  
**Binding contract:** [create-adsk.md](create-adsk.md) · [`profiles.json`](../../profiles.json)  
**Upstream pins:** [`recommended-skills.json`](../../recommended-skills.json)

---

## Why this model exists

[skills.sh topics](https://www.skills.sh/topic) already browse skills by domain (Design, Testing, Marketing, …). ADSK must not clone that axis as “design / docs / development profiles.”

ADSK differentiates on **kit adoption**: named depth + optional methodology compositions, Cursor wiring, config, and update/status — while leaving discovery to `npx skills` / skills.sh.

**Kill test (from create-adsk contract):** if the pitch needs a skill menu to explain value, cut scope.

---

## Two axes

```text
Profile  = how deep is the kit in this repo?     (adoption depth)
Pack     = which methodology contracts apply?    (consistency domains)
```

| Axis        | Source of truth (today)                                                                            | User-facing question                        |
| ----------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| **Profile** | `profiles` in [`profiles.json`](../../profiles.json)                                               | core / delivery / maintainer / skills-only  |
| **Pack**    | `optional_packs.packs` + `entry_ids` in [`recommended-skills.json`](../../recommended-skills.json) | `product-value-loop`, `engineering-methods` |

### Profiles (shipped)

| Profile       | Role                                                                         |
| ------------- | ---------------------------------------------------------------------------- |
| `core`        | Spec-driven delivery spine + Cursor commands                                 |
| `delivery`    | Core + DevOps strategy + release automation                                  |
| `maintainer`  | Delivery + skill authoring, README, supply-chain, PR authoring + stock rules |
| `skills-only` | All first-party skills; no `.cursor/` writes                                 |

Details: [create-adsk.md](create-adsk.md).

### Packs (shipped)

After profile choice, `create-adsk` offers a **pack multiselect** (defaults off). Copy: “Profile = kit depth”, “Packs = methodology contracts.”

| Pack id               | Playbook                                            | Entries (recommended-skills)                     |
| --------------------- | --------------------------------------------------- | ------------------------------------------------ |
| `product-value-loop`  | [product-value-loop.md](../product-value-loop.md)   | wondelai + deanpeters + competitive-intelligence |
| `engineering-methods` | [engineering-methods.md](../engineering-methods.md) | Superpowers subset (plans / TDD / debug)         |

Flags: `--packs <ids>` · `--with-optional-packs` (all). Config `optionalPacks` stores **pack ids**.

Upstream pack skills install **as authored** (often without ADSK `evals/`). First-party profile skills carry the kit eval harness. Adopter note: [using-adsk.md § Evaluating skills](../using-adsk.md#5-evaluating-skills-adopters).

A pack is **not** a skills.sh topic. It must include:

1. Skill list (first-party and/or pinned upstream)
2. Cursor commands/rules delta when relevant
3. Short playbook (stage map)
4. Explicit exclusions (`do_not_add` / pack-level “do not install”)
5. Trust pins + membership reflected in `.adsk/config.json` and `update` / `status`

---

## What we will not do

| Anti-pattern                                                                            | Why                                                                 |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Domain profiles named design / docs / CI / product as peers of core/delivery/maintainer | Recreates skills.sh topics; fails kill test                         |
| Free-form multi-select of every first-party or registry skill as primary UX             | Marketplace wrapper; forbidden by adopter product rules             |
| First-party skills that only restate LLM-common knowledge (generic “what is DDD”)       | No durable differentiation; compose Superpowers / skills.sh instead |
| Mixing pack choice into an arbitrary skill catalog browser                              | Breaks two-tool model                                               |

---

## Consistency domains → where they live

Map common “we need consistency here” asks to **profile depth** or **packs**, not new domain profiles:

| Consistency need                                                   | Prefer                                                                                                                                                                                     |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Spec → plan → implement → review                                   | Profile ≥ `core`                                                                                                                                                                           |
| Branching, CI/CD strategy, release automation                      | Profile ≥ `delivery`                                                                                                                                                                       |
| README standards, skill authoring, supply-chain gate, PR authoring | Profile `maintainer` (or grow a future docs/security **pack** when playbook-ready)                                                                                                         |
| Product discovery → roadmap → then SDD                             | Pack: `product-value-loop`                                                                                                                                                                 |
| TDD / systematic debug / writing-plans wired into implement        | Pack: `engineering-methods`                                                                                                                                                                |
| Design system / DB design conventions                              | Pack only when the org encodes **team decisions** (tokens, schemas, folder rules); until then point to skills.sh / optional upstream skills (e.g. `frontend-design` in recommended-skills) |

---

## Roadmap (product)

| Horizon   | Outcome                                                                                                             |
| --------- | ------------------------------------------------------------------------------------------------------------------- |
| **Done**  | Eng-lead docs; pack multiselect UX; `engineering-methods` + playbook                                                |
| **Later** | Additional packs only when playbook + pins + exclusions exist (e.g. security-ops, docs-ops) — never as topic clones |

Implementation must update together: `docs/product/create-adsk.md`, `profiles.json`, `.cursor/docs/specs/create-adsk.md`, and pointers in [using-adsk.md](../using-adsk.md) / README (see `.cursor/rules/adopter-product/`).

---

## Related

- [for-eng-leads.md](for-eng-leads.md) — pitch for eng leads
- [create-adsk.md](create-adsk.md) — product contract
- [using-adsk.md](../using-adsk.md) — how to adopt
- [lifecycle-coverage.md](../lifecycle-coverage.md) — coverage map
