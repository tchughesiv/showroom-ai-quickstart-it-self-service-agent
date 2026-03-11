# IT Self-Service Agent Showroom — Implementation Status

This document tracks implementation progress for the showroom content repository that accompanies the IT Self-Service Agent quickstart.

**Canonical quickstart:** [rh-ai-quickstart/it-self-service-agent](https://github.com/rh-ai-quickstart/it-self-service-agent)  
**Fork for this showroom:** [tchughesiv/self-service-agent-blueprint](https://github.com/tchughesiv/self-service-agent-blueprint/tree/ansible) (ansible branch) — Demo Mode lives here today; will merge to canonical once proven.

---

## Overview

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Install Agent Skills | ✅ Complete |
| 2 | Replace Template Content | ✅ Complete |
| 3 | Align with Quickstart Structure | ✅ Complete |
| 4 | UI Configuration & Assets | ✅ Complete |
| 5 | Local Dev & Validation | ✅ Complete |
| 6 | AgnosticV & Production | 🔲 Pending |

---

## Phase 1: Install Agent Skills — ✅ Complete

**Goal:** Install RHDP Showroom skills so Cursor (and other agentic tools) follow Red Hat best practices and Antora/AsciiDoc standards.

**Completed:**
- Installed RHDP Skills Marketplace showroom skills for Cursor
- Skills available: `/showroom:create-lab`, `/showroom:create-demo`, `/showroom:verify-content`, `/showroom:blog-generate`

**Reference:**
- [RHDP Skills Marketplace](https://github.com/rhpds/rhdp-skills-marketplace)
- [Showroom Skills](https://github.com/rhpds/rhdp-skills-marketplace/tree/main/showroom)

---

## Phase 2: Replace Template Content — ✅ Complete

**Goal:** Replace the showroom template boilerplate with IT self-service agent–specific content.

### 2a. Branding and Metadata ✅

| File | Changes |
|------|---------|
| `content/antora.yml` | Title set to "IT Self-Service Agent Quickstart"; AsciiDoc attributes for lab name, GUID, pagination |
| `site.yml` | Site title and URL updated for this showroom |
| `README.adoc` | Rewritten for IT self-service agent content; quick start and local dev instructions |

### 2b. Navigation ✅

| File | Changes |
|------|---------|
| `content/modules/ROOT/nav.adoc` | Replaced template nav with IT self-service agent structure |

**Structure:**
- Lab Overview
- Getting Started: Overview, Requirements and Setup
- Hands-On Modules: Deploy, Interact, Evaluations
- Conclusion and Next Steps

### 2c. Core Pages ✅

| Page | Purpose |
|------|---------|
| `index.adoc` | Lab overview, learning objectives, structure, key technologies |
| `01-overview.adoc` | Business context, target audience, architecture, related resources |
| `02-details.adoc` | Prerequisites, hardware/software requirements, setup checklist, troubleshooting |
| `03-module-01.adoc` | Deploy to OpenShift (clone, env vars, Helm, verify) |
| `04-module-02.adoc` | Interact with the agent via email (webmail UI; laptop refresh workflow) |
| `05-module-03.adoc` | Going Further — extensibility, evals, tracing, blog series |
| `99-conclusion.adoc` | Summary, optional integrations, customization, resources |

**Note:** Legacy template pages (e.g. quick-start, content-repo, agnosticv-config) remain in `content/modules/ROOT/pages/` but are not in the nav. They are still reachable by URL for reference.

---

## Phase 3: Align with Quickstart Structure — ✅ Complete

**Goal:** Ensure showroom content mirrors the quickstart structure and terminology; add variable injection for RHDP deployment.

**Completed:**
1. **Content-source mapping** — Cross-references from lab modules to quickstart guides
2. **Variable injection** — `antora.yml` has `guid: '%GUID%'`, `page-links` for Quickstart, Llama Stack, LangGraph
3. **Cross-references** — Links to guides in 01-overview, 05-module-03, 99-conclusion

---

## Phase 4: UI Configuration & Assets — ✅ Complete

**Goal:** Finalize the Showroom UI and add visual assets.

**Completed:**
1. **ui-config.yml** — OCP Console (${DOMAIN}), Quickstart Repo, Llama Stack Docs tabs
2. **Assets** — Mermaid architecture flowchart embedded in 01-overview.adoc (no separate image files)

---

## Phase 5: Local Dev & Validation — ✅ Complete

**Goal:** Establish a repeatable build and validation workflow.

**Completed:**
1. **Local preview** — README documents `podman run` and `podman-compose up`; `podman-compose.yaml` added for live reload
2. **Validation** — Run `/showroom:verify-content` in Cursor (requires RHDP skills)
3. **CI** — Existing `.github/workflows/gh-pages.yml` builds the site

---

## Phase 6: AgnosticV & Production — 🔲 Pending

**Goal:** Integrate with RHDP and prepare for org move.

**Planned:**
1. **AgnosticV catalog**
   - Add or update AgnosticV catalog item pointing to this content repo
   - Configure dev mode in `dev.yaml` for attribute verification

2. **Org move**
   - Prepare for move to `rh-ai-quickstart` org
   - Update URLs, references, and `site.yml` after move

3. **Production**
   - Pin content branch/tag in `prod.yaml`
   - Verify end-to-end deployment on RHDP

**Detailed guide:** See [docs/PHASE-6-GUIDE.md](docs/PHASE-6-GUIDE.md) for step-by-step instructions.

---

## Quick Reference

### Local Preview
```bash
podman run --rm --name antora -v $PWD:/antora:z -p 8080:8080 -i -t ghcr.io/juliaaano/antora-viewer
```
Open http://localhost:8080

### Validate Content
```
/showroom:verify-content
```
(Run in Cursor with RHDP skills installed)

### Key Repositories
- **This repo:** Showroom content (Antora/AsciiDoc)
- **Canonical quickstart:** https://github.com/rh-ai-quickstart/it-self-service-agent
- **Dev fork:** https://github.com/tchughesiv/self-service-agent-blueprint (ansible branch) — for development only
- **Template:** https://github.com/rhpds/showroom_template_nookbag
- **Skills:** https://github.com/rhpds/rhdp-skills-marketplace

### Install Mode
This showroom uses **demo** install mode (`make install INSTALL_MODE=demo`) for ephemeral demos — deploys Greenmail + demo values, no Knative operators required. Use `make uninstall` for removal.

### Audit
See [AUDIT.md](AUDIT.md) for the latest audit (issues, improvements, next steps).
