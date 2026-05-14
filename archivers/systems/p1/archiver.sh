#!/usr/bin/env bash
set -Eeuo pipefail

ARCHIVE_DIR="${ARCHIVE_DIR:-archives}"
IGNORE_FILE="${IGNORE_FILE:-7z_ignore.txt}"
SOURCE_PATH="${1:-}"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <source-path>

Environment overrides:
  ARCHIVE_DIR=archives
  IGNORE_FILE=7z_ignore.txt
EOF
}

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"
}

fail() {
  printf '[ERROR] %s\n' "$*" >&2
  exit "${2:-1}"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1" 127
}

safe_name() {
  basename "$1" | sed 's/[^A-Za-z0-9._-]/_/g'
}

main() {
  require_cmd 7z
  require_cmd nproc
  require_cmd date
  require_cmd sed

  [[ -n "$SOURCE_PATH" ]] || {
    usage >&2
    fail "Source path is required." 64
  }

  [[ -e "$SOURCE_PATH" ]] || fail "Source path does not exist: $SOURCE_PATH" 66

  mkdir -p "$ARCHIVE_DIR" || fail "Unable to create archive directory: $ARCHIVE_DIR" 73

  [[ -f "$IGNORE_FILE" ]] || {
    log "Ignore file not found. Creating empty ignore file: $IGNORE_FILE"
    : > "$IGNORE_FILE"
  }

  local source_name timestamp archive threads
  source_name="$(safe_name "$SOURCE_PATH")"
  timestamp="$(date -u '+%Y%m%d-%H%M%S')"
  archive="${ARCHIVE_DIR}/backup_${source_name}_${timestamp}.7z"
  threads="$(nproc)"

  log "Creating archive: $archive"
  log "Source: $SOURCE_PATH"
  log "Exclude file: $IGNORE_FILE"
  log "Threads: $threads"

  7z a "$archive" "$SOURCE_PATH" \
    -t7z \
    -mx=9 \
    -m0=lzma2 \
    -md=512m \
    -mfb=273 \
    -ms=on \
    -mmt="$threads" \
    "-xr@${IGNORE_FILE}"

  [[ -s "$archive" ]] || fail "Archive was not created or is empty: $archive" 74

  log "Archive created successfully: $archive"

  7z t "$archive" >/dev/null || fail "Archive integrity test failed: $archive" 75

  log "Archive integrity test passed."
}

main "$@"
