#!/bin/sh
# Install the Vale CLI from https://github.com/vale-cli/vale/releases (pinned in Makefile).
# Usage: install-vale.sh <version> <dest_dir>
set -eu

VERSION="${1:?version required}"
DEST="${2:?dest directory required}"

case "$(uname -s)" in
	Darwin)
		case "$(uname -m)" in
			arm64) ARCHIVE="vale_${VERSION}_macOS_arm64.tar.gz" ;;
			x86_64) ARCHIVE="vale_${VERSION}_macOS_64-bit.tar.gz" ;;
			*) echo "unsupported macOS machine: $(uname -m)" >&2; exit 1 ;;
		esac
		;;
	Linux)
		case "$(uname -m)" in
			aarch64 | arm64) ARCHIVE="vale_${VERSION}_Linux_arm64.tar.gz" ;;
			x86_64) ARCHIVE="vale_${VERSION}_Linux_64-bit.tar.gz" ;;
			*) echo "unsupported Linux machine: $(uname -m)" >&2; exit 1 ;;
		esac
		;;
	*)
		echo "unsupported OS: $(uname -s) (Vale supports macOS and Linux)" >&2
		exit 1
		;;
esac

URL="https://github.com/vale-cli/vale/releases/download/v${VERSION}/${ARCHIVE}"
mkdir -p "${DEST}"
TMP="${TMPDIR:-/tmp}/vale.${VERSION}.$$"
trap 'rm -f "${TMP}"' EXIT INT TERM

curl -fsSL -o "${TMP}" "${URL}"
tar -xzf "${TMP}" -C "${DEST}" vale
chmod +x "${DEST}/vale"
