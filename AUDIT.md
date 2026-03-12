# IT Self-Service Agent Showroom — Audit Report

**Audit date:** 2025-03-11  
**Branch/repo:** showroom-ai-quickstart-it-self-service-agent  
**Scope:** Content, implementation plan alignment, showroom docs/guides

---

## Executive Summary

The showroom content is in good shape and aligns with the IT Self-Service Agent quickstart (Demo Mode, email/webmail flow). Phases 1–5 of the implementation plan are complete. A few documentation gaps, stale references, and Phase 6 items remain.

---

## Phase Status vs. Implementation Plan

| Phase | Status | Notes |
|-------|--------|-------|
| 1. Install Agent Skills | ✅ Complete | RHDP skills installed |
| 2. Replace Template Content | ✅ Complete | See discrepancies below |
| 3. Align with Quickstart | ✅ Complete | Cross-refs, variable injection |
| 4. UI Config & Assets | ⚠️ Mostly complete | Mermaid inline; no image files in assets |
| 5. Local Dev & Validation | ✅ Complete | README, podman-compose, CI |
| 6. AgnosticV & Production | 🔲 Pending | Catalog, org move, prod verification |

---

## Issues Found

### 1. IMPLEMENTATION.md Stale Content (Phase 2c)

**Location:** IMPLEMENTATION.md, Core Pages table

**Issue:** Phase 2c describes pages that no longer match current content:

| Page | IMPLEMENTATION says | Actual content |
|------|----------------------|----------------|
| 04-module-02.adoc | "Interact with the agent via CLI (laptop refresh workflow)" | Interact via **email/webmail UI** |
| 05-module-03.adoc | "Evaluations and distributed tracing" | **Going Further** — extensibility, evals, tracing, blog series |

**Fix:** Update IMPLEMENTATION.md Phase 2c table to reflect current page purposes.

---

### 2. Index Learning Objective — Tracing

**Location:** index.adoc, "By the end of this workshop you will"

**Issue:** "Use distributed tracing to understand agent workflows" implies hands-on tracing. Module 3 covers tracing as an overview with links to guides; it’s not a core exercise.

**Suggestion:** Soften to "Understand how extensibility, evaluations, and tracing support production" or keep as aspirational and note it's optional.

---

### 3. Assets / Images

**Location:** Phase 4 says "assets/images/ created"

**Issue:** No image files in `assets/images/`. Architecture is a Mermaid diagram embedded in 01-overview.adoc.

**Status:** Acceptable — Mermaid avoids image maintenance. Consider removing or clarifying the "assets/images/ created" claim in IMPLEMENTATION.md.

---

### 4. 99-conclusion Accomplishments

**Location:** 99-conclusion.adoc, "What You Accomplished"

**Current:** "Ran evaluations and explored tracing (Module 3)"

**Note:** Module 3 is now "Going Further" (extensibility, evals, tracing). The line is still accurate for evals/tracing but could say "Explored extensibility, evals, and tracing (Module 3)" for clarity.

---

### 5. CI Workflow UI Bundle Override

**Location:** .github/workflows/gh-pages.yml

**Issue:** Build overrides site.yml to use `patternfly-6` ui-bundle instead of `rh-summit-2025` from site.yml. Intentional for gh-pages preview, but may differ from RHDP deployment.

**Status:** Document or confirm this is desired for GitHub Pages.

---

### 6. Legacy Template Pages

**Location:** content/modules/ROOT/pages/

**Present:** quick-start.adoc, content-repo.adoc, agnosticv-config.adoc, ocp4-role-reference.adoc, ui-config.adoc, etc. — not in nav, reachable by URL.

**Status:** Per IMPLEMENTATION, these are kept for reference. Consider a note in README or a 404 for unknown URLs if unwanted.

---

## Alignment with Showroom Template / Guides

- **Structure:** Matches workshop template (index, overview, details, modules 1–3, conclusion).
- **Terminology:** Uses "quickstart" (not "blueprint"), "IT Self-Service Agent".
- **Links:** External links use `window="_blank"`; internal xrefs stay in same tab.
- **Variable injection:** antora.yml has guid, page-links for Quickstart Repo, Llama Stack, LangGraph.

---

## Room for Improvement

1. **Screenshots:** Add 1–2 screenshots (e.g., webmail UI, successful laptop refresh) for faster orientation.
2. **Troubleshooting:** Expand 02-details.adoc with Demo Mode–specific items (e.g., Greenmail not ready, webmail URL missing).
3. **Dev mode:** If using RHDP dev mode, add a note in README about attribute verification.
4. **Validate content:** Run `/showroom:verify-content` (RHDP skills) before release.
5. **Blog series:** Part 3 and Part 4 are "forthcoming" in 05-module-03; plan to update when published.

---

## Next Steps (Priority Order)

1. **Update IMPLEMENTATION.md** — Fix Phase 2c page descriptions; clarify Phase 4 assets.
2. **Phase 6 — AgnosticV:** Add or update catalog item; configure dev mode in dev.yaml.
3. **Phase 6 — Org move:** When moving to rh-ai-quickstart, update site.yml url, any repo references.
4. **Phase 6 — Production:** Pin content branch/tag in prod.yaml; run end-to-end deployment.
5. **Optional:** Add webmail screenshots; expand troubleshooting; run verify-content.

---

## Quick Reference — Current State

| Item | Value |
|------|-------|
| Install mode | Demo (`make install INSTALL_MODE=demo`) |
| Clone source | rh-ai-quickstart/it-self-service-agent (dev branch; main when ready) |
| Core flow | Deploy → Interact via webmail → Going Further |
| Time to complete | 30–60 minutes |
| External links | Open in new tab |
| CI | gh-pages.yml builds on push to main |
