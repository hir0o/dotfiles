---
name: designing-for-understanding
description: Use when turning dense documents, chapters, specs, reports, or essays into self-contained HTML or web UI that must help readers grasp the core theme, claims, evidence, terms, and flow without changing the source meaning.
---

# Designing for Understanding

## Overview

This skill is for document-to-UI work where the goal is understanding, not decoration. The core rule is: **externalize the document's structure so readers do not have to reconstruct it in their head**.

If the UI is visually impressive but readers cannot tell the main claim, what supports it, and what to do next, it failed.

## Workflow: Single vs Parallel Variants

**Before doing any work, ask the user whether they want 1 version or 3 versions.** Do not assume. Ask explicitly, e.g. 「1バージョン作りますか、それとも異なる方向性で3バージョン並列で作りますか？」

- **1 version**: implement directly in the main context, following the rest of this skill.
- **3 versions**: spawn **3 subagents in parallel** (single message with 3 `Agent` tool calls), each producing an independent HTML file from the **same input**. Each subagent must:
  - Receive the full source input and the full content of this `SKILL.md` as briefing.
  - Be given a distinct **direction** so the three outputs are meaningfully different — not cosmetic reskins. Pick directions that vary the *meaning structure surfaced first*, not just the palette. Examples:
    - A: claim-evidence-first (lead with the main claims and their support)
    - B: misunderstanding-first (lead with what readers typically get wrong, then correct)
    - C: process/flow-first (lead with the decision or pipeline the source describes)
  - Write to a distinct output path (e.g. `variant-a.html`, `variant-b.html`, `variant-c.html`).
  - Return a short summary of the direction taken and the file path.

To produce real variation (not three near-identical layouts), tell each subagent which constraints are loose and which are hard:

- **Loosen** (encouraged to diverge): layout shell (topbar/sidebar presence, single vs two-column, hero size and density, section order), typographic emphasis, the specific UI module chosen for a given meaning element (e.g. concept map vs cascade vs comparison table as the "3-minute layer").
- **Hard constraints** (must hold in every variant): single scrollable page with no tab-based content hiding; the four meaning badges (`原文 / 要約 / 解釈 / 推測`) and their color mapping; every claim card links to evidence and example; quiz is 4-choice A/B/C/D with one correct + three plausible distractors; no domain metaphors that change meaning (dashboards, KPIs, scores).

The rule of thumb: loosen "how it looks", keep "what the labels mean". If a variant drops a hard constraint, it stops being a valid output of this skill — it is a different skill.

Do not run the 3 subagents sequentially — they are independent and must be dispatched in one message. After they return, present the three paths to the user side-by-side and let them choose or merge.

## When to Use

Use when:
- Converting a chapter, blog post, report, spec, memo, or essay into HTML
- Building a "reading UI", "learning UI", "explain this visually", or "understanding-first" page
- The source is dense, abstract, technical, or easy to misread
- The output must preserve meaning and label interpretation clearly

Do not use when:
- The source is already a task UI or app screen
- The goal is branding, marketing, or visual storytelling more than comprehension
- A simple summary or plain markdown is enough

## Core Pattern

### 1. Extract the meaning structure before designing

Always map the source into:
- Center theme
- Main claims
- Evidence
- Examples
- Prerequisite knowledge
- Likely misunderstandings
- Terms
- Process or flow
- Comparisons

If you cannot fill these buckets, do not start styling yet.

### 2. Design for the reader's understanding path

Build three layers:
- `30 seconds`: TL;DR and the central question
- `3 minutes`: overview map showing claim → evidence → example
- `drill down`: details, glossary, comparisons, comprehension check

Lead with the answer. Do not make readers open accordions to find the core claim.

### 3. Map meaning to UI modules

| Source element | UI module |
|---|---|
| Center theme | Hero + TL;DR |
| Claims and evidence | Claim cards |
| Relationships | SVG concept map or flowchart (show claim→evidence→example links, not just top-level categories) |
| Terms | Glossary |
| Misunderstandings | Warning callouts |
| Similar concepts | Comparison table |
| Long detail | Accordion |
| Learning transfer | 4-choice quiz with explanations (A/B/C/D, exactly one correct) |

### 4. Keep meaning boundaries visible

Mark each important block as one of:
- `原文` — source text quoted or closely paraphrased (e.g. "TTLは5分間である")
- `要約` — condensed restatement with no added meaning (e.g. a TL;DR of a paragraph)
- `解釈` — meaning you inferred from the source (e.g. labeling a paragraph as "main claim" when the source does not say so)
- `推測` — extrapolation beyond the source (e.g. "this likely also applies to streaming use cases" when the source does not discuss streaming)

All four labels must appear at least once if the UI contains any interpretive or extrapolated content. If you only used three, check whether you silently embedded a `推測` as `解釈`.

Never let inferred structure masquerade as source fact.

### 5. Verify understanding, not just coverage

Before finishing, perform each check and fix any failure:
- Open the page and read only the viewport without scrolling. If the center theme is not visible, move it above the fold.
- Pick any claim card. Verify it links to at least one evidence block and one example. If not, add the link.
- Search the page for every `解釈` and `推測` badge. If none exist, you likely embedded interpretation without labeling it.
- Resize the browser to 375px width. If the reading order breaks or key content is hidden, fix the layout.
- Read each quiz question. Every question must be a 4-choice (A/B/C/D) single-answer item with exactly one correct option and three plausible distractors (no "all of the above", no true/false, no free text). If any can be answered by copying a phrase from the page, rewrite it as a scenario or application question.

## Example: Linear Reproduction vs Meaning-First Structure

```html
<!-- BAD: mirrors source heading order, reader must read everything to find the point -->
<section><h2>はじめに</h2><p>...</p></section>
<section><h2>キャッシュの仕組み</h2><p>...</p></section>
<section><h2>バッチ推論</h2><p>...</p></section>
<section><h2>まとめ</h2><p>Core claim finally appears here</p></section>

<!-- GOOD: leads with answer, maps meaning to modules -->
<header class="hero"><h1>Core claim as headline</h1>
  <p class="badge">要約</p><p>TL;DR in one sentence</p></header>
<section class="concept-map"><!-- SVG: claim→evidence→example --></section>
<section class="claims"><article class="claim-card">
  <p class="badge">解釈</p><h3>Claim 1</h3>
  <p class="badge">原文</p><blockquote>Supporting evidence</blockquote>
</article></section>
<section class="warnings"><p class="badge">推測</p>
  <p>Extrapolation the source does not state</p></section>
```

## Visual Style

The visual language below is the default for this skill. It exists because understanding-first UIs need a calm, editorial feel — a dashboard-like or marketing-like look pushes readers to scan for KPIs instead of reading. Follow it unless the source genuinely demands a different register (e.g. a children's explainer, a printable handout). Even then, keep the structure modules; only the surface treatment changes.

### Design tokens

Use these as CSS custom properties. The palette is intentionally narrow — four meaning colors that map 1:1 to the four source-boundary badges, plus neutrals.

```css
:root {
  --bg: #0f0f0f;            /* page */
  --surface: #171717;       /* cards, sidebar, hero TL;DR */
  --surface2: #1f1f1f;      /* nested surfaces, hover states */
  --border: #2a2a2a;        /* hairlines */
  --text: #e8e8e8;          /* body */
  --muted: #888;            /* labels, secondary text */
  --accent:  #d4a843;       /* gold — primary accent, 解釈 badge */
  --accent2: #7eb3d4;       /* slate blue — evidence, 要約 badge */
  --warn:    #c9624a;       /* terracotta — misunderstandings, 推測 badge */
  --green:   #5a9e6f;       /* sage — correct/原文 badge */
  --mono: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace;
  --sans: 'Helvetica Neue', 'Arial', 'Hiragino Kaku Gothic ProN', 'Meiryo', sans-serif;
}
```

Body type: 15px / line-height 1.7. Hero title: 32px, weight 700, letter-spacing -0.02em. Section headings: 11px uppercase, letter-spacing 0.12em, muted color — they act as labels, not decoration.

### Layout shell

The page is a **single scrollable document**. Do not split content across tabbed views that hide/show via JS — browser back, deep links, find-in-page, and PDF export all break when content is conditionally hidden. The "30秒 / 3分 / drill-down" reading layers are achieved by **vertical order** (the hero and TL;DR come first, drill-down sections come later), not by separate routes.

Three regions, sticky:

- **Topbar** (48px, full width) — one short uppercase label on the left identifying the document (e.g. `推論コスト最適化`), nothing else competing for attention. On the right, anchor-link "section jumps" to the major landmarks (e.g. `中心テーマ / 主張 / 詳細 / 理解チェック`). These are `<a href="#id">`, not buttons — clicking updates the URL hash so browser back/forward and bookmarks work. Active section is highlighted via `IntersectionObserver`, with a 2px bottom border in `--accent`.
- **Sidebar** (220px, left) — section labels in uppercase muted, then anchor links to every section. Active link gets a 2px left border in `--accent` and a faint tinted background. Hide on `max-width: 768px`.
- **Main** — sections stacked vertically, separated by 1px `--border` lines, not by extra whitespace. Use `scroll-margin-top: 56px` on every section so anchor jumps clear the sticky topbar.

Padding: 56px horizontal on desktop, 24px on mobile. Vertical rhythm comes from section borders, not margins.

The reading layers map to scroll position:
- Above the fold (the first viewport): hero with eyebrow, title, TL;DR, axis pills.
- First scroll (3-minute layer): concept map, claim cards, misunderstandings.
- Further down (drill-down): per-axis detail blocks, comparison table, glossary, quiz.

### Module-to-style mapping

Extend the meaning→module table from earlier with these visual rules. The point is that every module already has a "shape" — don't reinvent it per document.

| Module | Visual treatment |
|---|---|
| Hero | Small `--accent` uppercase eyebrow → large title (allow `<br>` for rhythm) → TL;DR box with 3px `--accent` left border on `--surface2`, max-width 680px → row of "axis pills" (button-shaped anchors to the main axes) |
| Section heading | 11px uppercase muted label with the appropriate badge inline (e.g. `構造マップ <badge>解釈</badge>`) |
| Concept map | Inline SVG, viewBox-based, min-width 700px in a horizontal-scroll wrapper. Center node uses `--accent` stroke; satellite nodes use `--border` stroke on `--surface2` fill. Connectors are dashed `stroke-dasharray="4,3"` in `--border`. Show claim→evidence→example links explicitly, not just category boxes. |
| Claim cards | CSS grid `repeat(auto-fit, minmax(280px, 1fr))` with `gap: 1px` over a `--border` background — this creates hairline dividers without double borders. Each card's own background is `--surface` (not `--bg`) so the hairline reads as a divider, not a void. Each card: mono claim number in `--accent`, bold claim text, then a `border-top` evidence block with an `--accent2` uppercase label. |
| Warning callout | Accordion. 3px `--warn` left border, header with a mono `!` icon and 12px gap, body hidden by default. Inside the body, the "正しい理解" correction sits in a `--green` left-border box on a faint green tint. |
| Comparison table | `border-collapse: collapse`, 11px uppercase headers on `--surface2`, hairline row borders, no outer border. Use `.tag-good` (green) / `.tag-bad` (warn) inline spans for verdicts. |
| Glossary | Same 1px-gap grid trick as claim cards. Terms in `--mono` `--accent2`; definitions in 13px on `#aaa`. |
| Flow / cascade | Vertical "dot + line" connector pattern (10px dot, 1px line in `--border`) with box on the right. Branches: side-by-side `yes` (green-tinted border) / `no` (warn-tinted border) sub-boxes inside the parent box. |
| Quiz | One question per block, separated by hairlines. Mono question number in `--accent`. **Always 4 options labeled A / B / C / D** — never 2, 3, or 5+, and never multi-select. Exactly one option is correct; the other three are plausible distractors drawn from likely misreadings of the source. Options are `<button>` elements (left-aligned, full width, A/B/C/D letter in mono). On answer: correct → green border + tint; chosen-wrong → warn border + tint; reveal `.quiz-feedback` (left border colored by correctness) explaining why the correct answer is right *and* why each distractor is wrong. |

### Badge styling

The four source-boundary badges are visual primitives — render them identically every time so readers learn the color code:

```css
.badge { display: inline-block; font-size: 9px; font-weight: 700;
         letter-spacing: 0.08em; text-transform: uppercase;
         padding: 2px 6px; margin-left: 6px; vertical-align: middle; }
.badge-genmon   { /* 原文   */ background: rgba(90,158,111,0.15); color: #5a9e6f; border: 1px solid rgba(90,158,111,0.3); }
.badge-yoyaku   { /* 要約   */ background: rgba(126,179,212,0.15); color: #7eb3d4; border: 1px solid rgba(126,179,212,0.3); }
.badge-kaishaku { /* 解釈   */ background: rgba(212,168,67,0.15);  color: #d4a843; border: 1px solid rgba(212,168,67,0.3); }
.badge-suisoku  { /* 推測   */ background: rgba(201,98,74,0.15);  color: #c9624a; border: 1px solid rgba(201,98,74,0.3); }
```

The color-to-meaning binding (green=source, blue=summary, gold=interpretation, terracotta=extrapolation) is part of the skill — do not remap.

### Interactivity baseline

Single scrolling page. Topbar and sidebar anchors use `scroll-behavior: smooth` and update an active highlight via `IntersectionObserver`. Warning callouts toggle open/closed (use `<details>`/`<summary>` or equivalent — keep them keyboard-accessible). Quiz options disable after first answer and reveal feedback. Keep transitions short (0.15s) and avoid motion beyond color/border state changes — this is a reading UI, not a product tour.

Do not implement tab-based view switching that hides content with `display: none`. It breaks browser back/forward, deep links, find-in-page, screen-reader skimming, and print/PDF export. If you feel the page is "too long," that is a signal to tighten content or improve in-page navigation, not to hide sections behind tabs.

### What to avoid

- Light backgrounds, gradients, glassmorphism, drop shadows — they fight the editorial tone.
- More than the 4 meaning colors plus neutrals. New colors imply new meanings the source doesn't have.
- Icon libraries (emoji, lucide, etc.) for decoration. A single mono `!` for warnings is enough; the type hierarchy carries the rest.
- Card borders that compete with the 1px-gap grid trick — pick one separation strategy per surface.
- Large hero illustrations or stock-photo headers. The hero's job is to surface the claim, not to set a mood.

When the source is short enough that some modules would be empty (e.g. no misunderstandings exist), omit those modules rather than padding them. An empty warning section reads as "nothing to worry about," which is almost never true of the source.

## Implementation Rules

- Put the most important information first.
- Split big content into smaller, named sections.
- Use specific headings; headings are entry points, not decorations.
- Keep one main idea per card or block.
- Prefer active, descriptive section titles over generic titles like `Introduction`.
- Avoid FAQ dumps when the content can be structured properly.
- Use plain language for labels, even when the content is technical.
- Explain technical terms on first use, then collect them in a glossary.
- Use landmarks and heading hierarchy so screen-reader users can skim too.
- Use diagrams to show relationships, not to add visual spectacle.

## Common Mistakes

- Using a domain metaphor that changes meaning, such as a trading dashboard for neutral concepts
- Turning concepts into scores, rankings, KPIs, or green/red signals without source support
- Hiding the core claim inside collapsed sections
- Showing a list of ideas without showing how they connect
- Using quiz questions that only ask for memorized facts
- Writing headings that are vague, cute, or less specific than the text below them

## Quick Recovery Moves

If the page feels like a summary instead of an understanding UI:
- Add a claim → evidence → example map
- Rewrite headings so they carry the argument
- Split glossary from prerequisite knowledge
- Add misunderstanding callouts
- Replace recall-only quiz items with scenario-based 4-choice questions (A/B/C/D, one correct + three plausible distractors)

## References

See [references.md](./references.md) for the source material behind these rules.
