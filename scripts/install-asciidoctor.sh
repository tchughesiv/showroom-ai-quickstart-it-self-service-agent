#!/bin/sh
# Install Asciidoctor for Vale's AsciiDoc parser (lintAdoc). Idempotent.
set -eu
GEMBIN="${1:?bindir required}"

if command -v asciidoctor >/dev/null 2>&1; then
  echo "asciidoctor already on PATH"
  exit 0
fi

if ! command -v gem >/dev/null 2>&1; then
  echo "Vale needs the asciidoctor CLI for .adoc. Install one of:" >&2
  echo "  brew install asciidoctor" >&2
  echo "  sudo apt install asciidoctor" >&2
  echo "  Or install Ruby, then re-run: make install" >&2
  exit 1
fi

GEM_HOME="$(dirname "$GEMBIN")/rubygems"
export GEM_HOME
mkdir -p "$GEM_HOME" "$GEMBIN"
gem install --no-document --bindir "$GEMBIN" asciidoctor
