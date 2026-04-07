# Antora site playbook (content + UI). Requires Node.js for npx.
PLAYBOOK   := site.yml
ANTORA     := npx --yes @antora/cli@3.1
YAML_FILES := site.yml content/antora.yml ui-config.yml podman-compose.yaml
NPM_STAMP    := node_modules/.make-npm-stamp

PYTHON           ?= python3
VENV             := .venv
VENV_BIN         := $(VENV)/bin
YAMLLINT         := $(VENV_BIN)/yamllint
REQUIREMENTS_DEV := requirements-dev.txt
INSTALL_STAMP    := $(VENV)/.make-install-stamp

# Vale: official binary vendored under .tools/ (see scripts/install-vale.sh)
VALE_VERSION     := 3.14.1
TOOLS_VALE_DIR   := .tools/vale
VALE             := $(abspath $(TOOLS_VALE_DIR)/vale)
VALE_STAMP       := $(TOOLS_VALE_DIR)/.installed-$(VALE_VERSION)

# Asciidoctor: Vale's AsciiDoc backend shells out to `asciidoctor` (Ruby gem into .tools/gem-bin if missing on PATH)
TOOLS_GEM_BIN    := .tools/gem-bin
TOOLS_RUBY_GEMS  := .tools/rubygems
ASCIDOCTOR_STAMP := $(TOOLS_GEM_BIN)/.installed

RUN_PORT ?= 8080
PRETTIER := npx --yes prettier@3

# Local preview (same image as README / podman-compose). Override on SELinux: PODMAN_VOL_SUFFIX=:z
PODMAN               ?= podman
ANTORA_VIEWER_IMAGE  ?= ghcr.io/juliaaano/antora-viewer:latest
PODMAN_VOL_SUFFIX    ?=

.PHONY: help install install-force uninstall build check clean distclean lint lint-yaml lint-vale format run serve vale-sync

help:
	@echo "Targets:"
	@echo "  install        Create .venv (yamllint) + Vale $(VALE_VERSION) + Asciidoctor for Vale; run vale sync"
	@echo "  install-force  Same as install after uninstall (full redo of .venv and .tools)"
	@echo "  uninstall      Remove .venv and .tools/"
	@echo "  build / check  Generate www/ (npx Antora; local npm ci for Mermaid — Podman has no global ext)"
	@echo "  run            Local: npm ci then Podman mount (so site.yml Mermaid ext resolves); http://127.0.0.1:$(RUN_PORT)/"
	@echo "  serve          make check then Python http.server on www/ (needs Node; no Podman)"
	@echo "  format         Prettier --write on playbook/config YAML only (not .adoc)"
	@echo "  lint           lint-yaml + lint-vale (run install first)"
	@echo "  lint-yaml      yamllint only (needs .venv from install)"
	@echo "  lint-vale      Vale on content/modules/ROOT (needs Vale + asciidoctor from install)"
	@echo "  vale-sync      Re-run vale sync (after editing Packages in .vale.ini)"
	@echo "  clean          Remove www/ and Antora .cache/"
	@echo "  distclean      clean + uninstall + rm -rf node_modules"

$(NPM_STAMP): package.json package-lock.json
	npm ci --no-fund
	touch $(NPM_STAMP)

$(INSTALL_STAMP): $(REQUIREMENTS_DEV)
	$(PYTHON) -m venv $(VENV)
	$(VENV_BIN)/pip install -U pip -q
	$(VENV_BIN)/pip install -r $(REQUIREMENTS_DEV)
	touch $(INSTALL_STAMP)

$(VALE_STAMP): scripts/install-vale.sh
	@echo "Installing Vale v$(VALE_VERSION) into $(TOOLS_VALE_DIR) ..."
	sh scripts/install-vale.sh "$(VALE_VERSION)" "$(TOOLS_VALE_DIR)"
	@"$(VALE)" sync
	touch $(VALE_STAMP)

$(ASCIDOCTOR_STAMP): scripts/install-asciidoctor.sh
	@echo "Ensuring asciidoctor for Vale (gem into $(TOOLS_GEM_BIN) if not on PATH) ..."
	@mkdir -p $(TOOLS_GEM_BIN)
	sh scripts/install-asciidoctor.sh "$(abspath $(TOOLS_GEM_BIN))"
	touch $(ASCIDOCTOR_STAMP)

install: $(INSTALL_STAMP) $(VALE_STAMP) $(ASCIDOCTOR_STAMP)
	@echo "Ready: yamllint in $(VENV), Vale $(VALE_VERSION) in $(TOOLS_VALE_DIR), asciidoctor for Vale (lint-vale)."
	@echo "Tip: make install-force recreates .venv and .tools; make vale-sync refreshes Vale packages after .vale.ini changes."

install-force: uninstall
	$(MAKE) install

uninstall:
	rm -rf $(VENV) .tools

build check: $(PLAYBOOK) $(NPM_STAMP)
	$(ANTORA) $(PLAYBOOK)

lint: lint-yaml lint-vale

lint-yaml: $(INSTALL_STAMP)
	$(YAMLLINT) -c .yamllint $(YAML_FILES)

lint-vale: $(INSTALL_STAMP) $(VALE_STAMP) $(ASCIDOCTOR_STAMP)
	@if [ -x "$(abspath $(TOOLS_GEM_BIN))/asciidoctor" ]; then \
		PATH="$(abspath $(TOOLS_GEM_BIN)):$$PATH" \
		GEM_HOME="$(abspath $(TOOLS_RUBY_GEMS))" \
		GEM_PATH="$(abspath $(TOOLS_RUBY_GEMS))" \
		"$(VALE)" content/modules/ROOT; \
	else \
		"$(VALE)" content/modules/ROOT; \
	fi

vale-sync: $(VALE_STAMP)
	@"$(VALE)" sync

format:
	@echo "Formatting YAML: $(YAML_FILES)"
	$(PRETTIER) --write $(YAML_FILES)

run: $(NPM_STAMP)
	@echo "Antora viewer — open http://127.0.0.1:$(RUN_PORT)/ (Ctrl+C to stop). SELinux: make run PODMAN_VOL_SUFFIX=:z"
	$(PODMAN) run --rm --name antora \
		-v "$(CURDIR):/antora$(PODMAN_VOL_SUFFIX)" \
		-p $(RUN_PORT):8080 \
		-i -t \
		$(ANTORA_VIEWER_IMAGE)

serve: check
	@echo "Serving ./www — open http://127.0.0.1:$(RUN_PORT)/modules/index.html (Ctrl+C to stop)"
	cd www && $(PYTHON) -m http.server $(RUN_PORT) --bind 127.0.0.1

clean:
	rm -rf www .cache

distclean: clean uninstall
	rm -rf node_modules
