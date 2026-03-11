# Phase 6: AgnosticV & Production — Detailed Implementation Guide

This guide walks through completing Phase 6 of the IT Self-Service Agent Showroom: integrating with RHDP via AgnosticV, preparing for org move, and production rollout.

---

## RHDP Engineer Pattern — 3 Steps (No Secrets Required)

Per RHDP Showroom engineers, adding Showroom to an AgnosticV catalog item is:

. *Add the collection* — Declare the Showroom collection in `requirements_content`
. *Call it* — Add `agnosticd.showroom.ocp4_workload_showroom` to workloads (almost always last)
. *Set its vars* — Content repo, ref, terminal type, and optionally `passthrough_user_data`

Tabs/links (OCP Console, Quickstart Repo, etc.) are configured in `ui-config.yml` in the *showroom content repo* — not in the catalog.

---

## Prerequisites

- Phases 1–5 complete (content, UI config, local dev)
- Content repo: `showroom-ai-quickstart-it-self-service-agent` (or target org/repo after move)
- Access to the [AgnosticV](https://github.com/rhpds/agnosticv) repository
- Familiarity with YAML, Ansible, and RHDP demo platform
- RHDP admin access for catalog sync and provisioning

---

## Part 1: AgnosticV Catalog Item

### 1.1 Decide on Catalog Item Strategy

**Option A — New catalog item:** Create a dedicated catalog item for the IT Self-Service Agent showroom (e.g. `agd_v2/it-self-service-agent-showroom`).

**Option B — Extend existing:** If an IT Self-Service Agent or AI quickstart catalog item already exists, add Showroom as a workload.

For a new showroom, Option A is typical.

### 1.2 Create the Catalog Item Directory

In your AgnosticV fork or branch:

```bash
cd agnosticv
mkdir -p agd_v2/it-self-service-agent-showroom
cd agd_v2/it-self-service-agent-showroom
```

### 1.3 Create `common.yaml`

Create `common.yaml` with the Showroom collection and content repo settings:

```yaml
# IT Self-Service Agent Showroom — common configuration
# Used for both dev and prod; prod.yaml overrides for version pinning

# Step 1: Add the collection
requirements_content:
  collections:
    - name: https://github.com/agnosticd/showroom.git
      type: git
      version: "v1.5.6"   # Pin to a release tag; check https://github.com/agnosticd/showroom/tags

# Step 2: Call it (almost always last)
workloads:
  - agnosticd.showroom.ocp4_workload_ocp_console_embed   # Optional: OCP console iframe tab
  - agnosticd.showroom.ocp4_workload_showroom

# Step 3: Set its vars
# -------------------------------------------------------------------
# Workload: ocp4_workload_showroom
# -------------------------------------------------------------------
ocp4_workload_showroom_content_git_repo: https://github.com/tchughesiv/showroom-ai-quickstart-it-self-service-agent
ocp4_workload_showroom_content_git_repo_ref: main
ocp4_workload_showroom_content_antora_playbook: site.yml

# Tabs (OCP Console, Quickstart Repo, etc.) are in ui-config.yml in the showroom repo

# Terminals — choose one:
# Option A: Showroom terminal (container with oc/helm pre-installed; use when cluster is in same env)
ocp4_workload_showroom_terminal_type: showroom
ocp4_workload_showroom_terminal_image: quay.io/juliaaano/openshift-showroom-terminal-ocp:2025-12-02

# Pass user_data (GUID, domain, URLs) through for ui-config tabs that use ${DOMAIN}
ocp4_workload_showroom_passthrough_user_data: true

# Option B: Wetty with auto-SSH to bastion (use when catalog provisions a bastion host)
# ocp4_workload_showroom_terminal_type: wetty
# ocp4_workload_showroom_wetty_ssh_bastion_login: true

# Option C: Content-only (no terminal)
# ocp4_workload_showroom_terminal_type: ""
# ocp4_workload_showroom_content_only: true
```

**Notes:**
- **Terminal type:** `showroom` uses a container image with `oc`/`helm` pre-installed; typical when the catalog provisions a cluster and users need CLI access. `wetty` uses SSH to a bastion. Coordinate with the RHDP engineer for your catalog's topology (cluster, bastion, console embed).
- **passthrough_user_data:** Enables `${DOMAIN}` and other placeholders in `ui-config.yml` tabs.
- **ocp4_workload_ocp_console_embed:** Optional; embeds the OCP web console as an iframe tab.

### 1.4 Create `dev.yaml` — Dev Mode for Attribute Verification

Create `dev.yaml` to enable Showroom dev mode when developing content:

```yaml
# Dev overrides — NEVER use in prod
ocp4_workload_showroom_enable_dev_mode: true
```

**What dev mode does:**
- Displays an attribute reference page with all `user_data` values (GUID, domain, URLs, etc.)
- Exposes unlisted pages in the nav for testing
- Helps verify that `%GUID%`, `${DOMAIN}`, and other placeholders resolve correctly

**Important:** Only set this in `dev.yaml`, never in `common.yaml` or `prod.yaml`.

### 1.5 Create `prod.yaml` — Version Pinning for Production

Create `prod.yaml` to pin the content repo to a release tag:

```yaml
# Production overrides — pin content to a known-good ref
ocp4_workload_showroom_content_git_repo_ref: v1.0.0
```

**Critical:** Never ship `main` to production. Use a git tag (e.g. `v1.0.0`) or a known-good commit SHA. Create the tag after content is validated:

```bash
cd showroom-ai-quickstart-it-self-service-agent
git tag v1.0.0
git push origin v1.0.0
```

### 1.6 Create `description.adoc` (Catalog Description)

Create `description.adoc` for the demo.redhat.com catalog entry:

```asciidoc
= IT Self-Service Agent Quickstart Lab

Deploy and use the IT Self-Service Agent for IT process automation on Red Hat OpenShift.

*Demo Mode* — deploys Greenmail (test email server) and completes the laptop refresh flow via webmail.
*Time:* 30–60 minutes (cluster and LLM ready)

*Prerequisites:* OpenShift cluster, LLM endpoint (Model as a Service via LLM_URL), Helm, oc/kubectl.
```

### 1.7 Add Catalog Item to AgnosticV

1. Fork [rhpds/agnosticv](https://github.com/rhpds/agnosticv) or work in a branch
2. Add your `agd_v2/it-self-service-agent-showroom/` directory with `common.yaml`, `dev.yaml`, `prod.yaml`, `description.adoc`
3. Open a PR; follow AgnosticV contribution guidelines for catalog item review
4. After merge, wait for catalog sync on demo.redhat.com

---

## Part 2: Org Move to rh-ai-quickstart

When the showroom and/or quickstart move to the `rh-ai-quickstart` organization:

### 2.1 Update Content Repo URL

In AgnosticV `common.yaml`:
```yaml
ocp4_workload_showroom_content_git_repo: https://github.com/rh-ai-quickstart/showroom-ai-quickstart-it-self-service-agent
```

### 2.2 Update `site.yml` (in Content Repo)

```yaml
site:
  title: IT Self-Service Agent Quickstart
  url: https://github.com/rh-ai-quickstart/showroom-ai-quickstart-it-self-service-agent
  start_page: modules::index.adoc
```

### 2.3 Update Clone Instructions (Content Repo)

When the quickstart merges Demo Mode to canonical, update:

- `03-module-01.adoc` — change clone URL from `tchughesiv/self-service-agent-blueprint` (ansible branch) to `rh-ai-quickstart/it-self-service-agent` (main)
- `02-details.adoc` — Pre-Workshop Checklist, repo reference
- `antora.yml` — page-links `Quickstart Repo` URL
- `ui-config.yml` — Quickstart Repo tab URL
- `README.adoc` — fork note
- `IMPLEMENTATION.md` — canonical vs fork references

### 2.4 Search and Replace

Run a grep for:
- `tchughesiv/self-service-agent-blueprint`
- `tchughesiv/showroom-ai-quickstart-it-self-service-agent`
- `ansible` (branch name)

Update to canonical URLs and `main` branch where appropriate.

---

## Part 3: Production Verification

### 3.1 Content Validation

Before tagging for production:

1. Run `/showroom:verify-content` in Cursor (requires RHDP skills)
2. Preview locally: `podman-compose up` and walk through all modules
3. Check all external links (blogs, GitHub, guides)
4. Verify `ui-config.yml` tabs work with `${DOMAIN}` when deployed

### 3.2 Create Release Tag

```bash
cd showroom-ai-quickstart-it-self-service-agent
git checkout main
git pull origin main
# Verify all tests pass, content is ready
git tag v1.0.0 -m "IT Self-Service Agent showroom v1.0.0"
git push origin v1.0.0
```

### 3.3 Update `prod.yaml` in AgnosticV

```yaml
ocp4_workload_showroom_content_git_repo_ref: v1.0.0
```

### 3.4 End-to-End Test on RHDP

1. Order the catalog item from demo.redhat.com (use dev environment first with `main` ref)
2. Wait for provisioning
3. Open the Showroom URL from the access information
4. Complete the lab flow: Overview → Requirements → Module 1 (Deploy) → Module 2 (Webmail) → Module 3 (Going Further)
5. Verify OCP Console tab (if enabled) loads with correct cluster
6. Verify Quickstart Repo tab points to correct repo
7. Test with prod.yaml (pinned tag) and confirm same behavior

### 3.5 Troubleshooting Production

| Issue | Check |
|-------|-------|
| Showroom 404 or blank | Content repo URL, ref, antora playbook path |
| Tabs don't load | ui-config.yml; `${DOMAIN}` passed from user_data |
| Attributes not substituted | Dev mode for debugging; verify user_data in AgnosticV |
| OCP console embed fails | ocp4_workload_ocp_console_embed ordering; cluster URL |

---

## Part 4: Checklist Summary

- [ ] Create `agd_v2/it-self-service-agent-showroom/` in AgnosticV
- [ ] Add `common.yaml` (collection, workloads, content repo)
- [ ] Add `dev.yaml` (enable dev mode)
- [ ] Add `prod.yaml` (pin content ref to tag)
- [ ] Add `description.adoc`
- [ ] Open PR to AgnosticV; get review/merge
- [ ] Verify catalog sync on demo.redhat.com
- [ ] Order catalog item; run E2E test (dev env)
- [ ] Tag content repo (e.g. v1.0.0)
- [ ] Update prod.yaml ref; test prod path
- [ ] When moving to rh-ai-quickstart: update all repo URLs

---

## Discuss with RHDP Engineer

When wiring the catalog item, confirm with the Showroom team:

* **Consoles** — OCP console embed (`ocp4_workload_ocp_console_embed`); cluster URL and permissions
* **Terminals** — `showroom` vs `wetty` vs content-only; which image/tag; bastion vs in-cluster
* **Topology** — Does this catalog provision a cluster? Bastion? Multi-user?

---

## References

- [AgnosticV](https://github.com/rhpds/agnosticv)
- [Showroom content-repo docs](https://rhpds.github.io/showroom_template_nookbag/modules/content-repo.html)
- [AgnosticV config](https://rhpds.github.io/showroom_template_nookbag/modules/agnosticv-config.html) (in legacy template pages)
- [tests/showroom-ocp4](https://github.com/rhpds/agnosticv/tree/main/tests/showroom-ocp4) — minimal OCP4 example
- [aap-multiinstance-workshop](https://github.com/rhpds/agnosticv/tree/main/agd_v2/aap-multiinstance-workshop) — production workshop example
