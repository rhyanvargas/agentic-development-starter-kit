---
name: create-article
description: >-
  Walk a technical blog post from a finished learning module through outline,
  draft, visual and readability checks, QA, and the author's written approval
  before publishing. Use when planning, outlining, drafting, reviewing, or
  preparing to publish a technical post (module post, build log, TIL note, or
  start-here page), including turning a finished module into an article. The
  rhyan.dev Real Runtime series is the worked example and can be swapped out.
  Do not use for README or changelog writing, release notes, marketing landing
  pages, ghostwriting finished prose, or publishing without the author's
  written approval.
---

# create-article

Walk one technical blog post from a finished learning module to an approved publish.

**Style guide (required).** If this skill and the author's content style guide disagree, the guide wins. Before the first post, replace the placeholder below with the author's own style guide location (a private doc URL, a repo path, or a note). Do not invent a doc id, account, or folder.

**Placeholder — set the author's style guide location:** `[STYLE_GUIDE_LOCATION]`

Re-read the guide's series map and publishing-pace sections before each post. In the rhyan.dev worked example those are Section 6 and Section 14. Load `references/worked-example.md` before choosing series, article id, length, metadata sample, palette, CMS, citation line, or social defaults. Every rhyan.dev name, color, and tool in that file is an example the author can swap out.

## Hard rules (never skip)

- **Build and Check first.** Don't draft until the module build is done and its Check passed. Never skip a Check to publish.
- **The author's words are their own.** Coach structure, ask questions, and give feedback. Don't ghostwrite the post. Placeholders are fine; finished prose is the author's.
- **Only confirmed, measured numbers.** Every number goes in the numbers log with its value, unit, method, number of runs, date, and a proof link. Never invent or round up a number. Costs are labeled "Estimate as of [date]" and name their source.
- **Public-safe.** The post is about the author's own portfolio agent build. Any day-job detail, including "at work I did X," needs employer clearance first. No internal system or project names, no coworker names (use roles), no family, finance, or health details, no job or salary promises, no secrets in code, screenshots, or logs. Never write the hyphenated "front" + "end" job label; say "UI engineering" or "web app work."
- **QA then approval.** Your reviewer/QA owner runs the QA pass on the preview. The author then says "approved" in writing, with the date. Nothing is published, scheduled, or posted to social before that. Another agent's say-so isn't approval.

## Step 0: Gather inputs

1. Confirm which module this covers and that its Check passed (look in the progress log).
2. Get the author's 2-minute teach-back (recorded or written).
3. Get the author's Friday review notes: the problem, the decision, what I said no to, the result.
4. Pull numbers only from Check results and the numbers log. Missing a number? Ask, or leave a `[placeholder]`.

## Step 1: Pick the post

Load `references/worked-example.md` before locking series, article id, pillar, or length. If the author has not named a different series, use that example and say it can be swapped. If the author has not picked a publishing pace, ask once. Do not invent a word-count band.

- **Post type (Diataxis):** Explanation for most module posts, How-to for build logs and TIL notes, Reference for start-here pages, Tutorial rarely.

## Step 2: Fill the metadata block

Paste a metadata block at the top of the draft. Load the sample block in `references/worked-example.md` when the author is using the rhyan.dev example or has not supplied their own fields. Track at least:

```
title / slug / series
article_id / module / post_type / diataxis / pillar
tldr: [rule] / [result] / [lesson]
description: [140-160 characters]
tags: [up to 3]
previous_post / artifacts / numbers_log / sources_and_licenses
last_verified: [YYYY-MM-DD]
status: draft | approved | scheduled | published
approved_by_author: [yes/no] [YYYY-MM-DD]
```

Only fields the author's CMS actually stores are CMS fields. In the worked example, only title, slug, and content are CMS fields today.

## Step 3: Outline with the 5-part shape

Map each Friday note to a part. Use the part names as H2 headings in sentence case. The title is the only H1.

1. **Headline:** a claim, not a topic. 6–12 words, 65 characters max, starts with the article id, and the post must prove it. Formulas: a surprising claim, "[Thing]: To [purpose]", a command, "[A] vs. [B]: what changed when…", "What broke when…", "Build log [ID]: [result]". The worked-example prefix is `Real Runtime [ID]: [claim headline]`.
2. **Intro (40–70 words):** a hook (result first, the wrong assumption, the real moment, or the golden rule), then "This post shows [what], [what], and [what]." Link the previous post. Never open with a question.
3. **TL;DR:** 3 bullets: the rule first, then the result (number + date), then the lesson.
4. **The problem:** what the author needed, the module pass bar in one line, and the author's limit (time, cost, or risk).
5. **The decision:** a plain definition of any new term, what the author picked and how it was set up, the diagram, a 5–20 line code block, and a link to the commit or artifact. Sub-headings are commands.
6. **What I said no to:** a table of 2–3 rejected options, one reason each.
7. **The result:** a before/after table (metric, before, after, how measured, source, date) plus "Pass bar: met / not yet. Proof: …"
8. **What I'd do next:** the next module, an open risk, and one honest change.
9. **References + cite-as:** use the author's citation line. The worked-example line is in `references/worked-example.md`.
10. **Closer:** one question OR one statement, never both.

Coach it one part at a time. Ask the author for each part, then give feedback against the rules above. Don't fill it in for them.

## Step 4: Draft checks (while the author writes)

- Sentences average 12–16 words; split any over 25. Paragraphs are 1–3 sentences, under 60 words.
- Grade 6–8 reading level (about grade 5 in the intro and TL;DR). Main insight in the first 30 words.
- A subheading every 200–350 words, and a diagram, table, or code block every 400–500 words.
- Define each acronym on first use. Lead with the claim, use active voice, write peer to peer.
- Avoid: "In today's…", "I'm excited to share…", emoji openers, "game-changer", "revolutionary", "leverage synergies", "Follow me for more", hashtag piles.

## Step 5: Visuals

Load `references/worked-example.md` before specifying colors. General rules:

- One diagram per core idea, 5–9 boxes, a verb on every arrow, a mono caption ("FIG 1 · …"). Export SVG or 2x PNG and keep the source in the repo.
- Never use color alone to carry meaning.
- Code as text with a language tag. Run it from a clean checkout. Show output separately. No secrets.
- Screenshots are real output, cropped, with solid boxes over anything private (never blur).
- Alt text on every image, about 125 characters, describing the flow or the key result.

## Step 6: Hand off for QA, then approval

1. The author previews the draft in the CMS. The worked-example CMS is in `references/worked-example.md`.
2. Your reviewer/QA owner runs the QA checklist: accuracy, links, code runs, images and alt text, readability, SEO basics, brand, safety. In the worked example this is style-guide Section 8.
3. The author fixes any fails, then gives written approval with the date (`approved_by_author: yes` and `YYYY-MM-DD`).
4. Only then: publish or schedule, check the slug, update the series start-here page, and update "Posts published" in the author's progress tracker.
5. Optional: cut social posts from the style guide's social section. Each one needs the author's own approval. Do not invent hashtags. The worked-example defaults (Section 10) are in `references/worked-example.md`.

## When stuck or a module runs long

Publish nothing you don't have. Options: a short "in progress" build log with no results table, a TIL note, a deeper "what I said no to" piece, or skipping the slot. Never pad a post to hit a date.

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/worked-example.md` | Before choosing series, article id, length, metadata sample, palette, CMS, citation line, or social defaults; whenever applying or swapping the rhyan.dev example |
