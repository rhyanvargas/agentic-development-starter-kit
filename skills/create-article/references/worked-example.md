# Worked example — rhyan.dev (swap this out)

Load when `SKILL.md` tells you to pick series, article id, length, metadata, palette, CMS, citation, or social defaults.

This file is an example from the rhyan.dev technical blog. Series names, palette, CMS, citation, hashtags, and section numbers belong to that example. Replace them when the author uses a different guide. The style guide location is the `[STYLE_GUIDE_LOCATION]` placeholder in `SKILL.md`, not a doc id or account name.

Example guide title: "rhyan.dev Technical Blog — Content Style Guide."

| Example section | What it decides |
|-----------------|-----------------|
| Section 6 | Series map |
| Section 8 | QA checklist |
| Section 10 | Social posts |
| Section 14 | Publishing pace |

Re-read Section 6 and Section 14 before each post when the author is still on this example, because the pace and series choices may have changed.

## Series map (example Section 6)

- **Series values:** Real Runtime | FDE Craft | Electives | TIL
- **Track name:** AI FDE Track, "Real Runtime" series
- **Pillars:** P1 agentic AI systems, P2 AI-first engineering workflows, P3 mental models for builders
- **Pace:** Option A or Option B. If the author has not picked one, ask once.
- **Option B slower start:** modules 0a and 0b combine into "Real Runtime 0a–0b, Part 1."

## Length (example Section 14)

| Pace / type | Band |
|-------------|------|
| Option B module post | Ships at 500–800 words with one diagram. Aims for 800–1,200 (a target, not a gate). |
| Option A module post | 2,000–3,000 words. Up to 4,000 for Modules 5, 6, 7, 16, and 18. |
| Build log or TIL note | 300–800 words |

Do not invent a band that is not in the author's guide or this table.

## Metadata sample

Only title, slug, and content are CMS fields in this example. The rest are editorial.

```
title: Real Runtime [ID]: [claim headline]
slug: real-runtime-[id]-[3-6-words]
series: Real Runtime | FDE Craft | Electives | TIL
article_id / module / post_type / diataxis / pillar
tldr: [rule] / [result] / [lesson]
description: [140-160 characters]
tags: [up to 3]
previous_post / artifacts / numbers_log / sources_and_licenses
last_verified: [YYYY-MM-DD]
status: draft | approved | scheduled | published
approved_by_author: [yes/no] [YYYY-MM-DD]
```

## Cite-as (example)

Vargas, Rhyan. "[Title]." rhyan.dev, [date]. URL.

Swap the name and site when the author is not publishing on rhyan.dev.

## Palette (example)

Dark brand palette. Never use color alone to carry meaning.

| Role | Value |
|------|--------|
| Ink | `#080C14` |
| Surface | `#0E1520` |
| Text | `#E2EAF4` |
| Blue | `#3B82F6` |
| Cyan (featured path) | `#22D3EE` |
| Purple (dashed outline for rejected options) | `#A78BFA` |
| Slate captions | `#64748B`, 14px or larger |

## CMS and social (example)

- **CMS:** Payload. Drafts, autosave, and live preview are on. Swap this if the author uses a different CMS.
- **QA:** your reviewer/QA owner runs example Section 8 on the preview.
- **After written approval:** update "Posts published" in the author's progress tracker.
- **Social (example Section 10):** each post needs the author's own approval. Use at most 3 hashtags, with `#AIEngineering` first, and put the link in the first comment. Swap the hashtags for the author's own.
