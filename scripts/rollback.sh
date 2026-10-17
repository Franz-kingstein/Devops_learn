#!/usr/bin/env bash
# rollback.sh - runs ON THE AZURE VM (invoked by Jenkins on build failure)
# Purpose: reset /opt/app to the previous commit saved by deploy.sh and
#          rebuild the containers with that known-good code.
set -euo pipefail

APP_DIR="/opt/app"
PREV_COMMIT_FILE="$APP_DIR/.prev_commit"

log() { echo "[rollback] $*"; }

# ---------- 1. Check that a rollback target exists ----------
if [ ! -f "$PREV_COMMIT_FILE" ]; then
    log "ERROR: No $PREV_COMMIT_FILE found - nothing to roll back to."
    log "First deploy failed before a previous commit was saved."
    exit 1
fi

PREV_COMMIT="$(cat "$PREV_COMMIT_FILE")"

if [ -z "$PREV_COMMIT" ]; then
    log "ERROR: .prev_commit is empty - cannot roll back."
    exit 1
fi

cd "$APP_DIR"

# ---------- 2. Verify the commit still exists in the repo ----------
if ! git cat-file -e "$PREV_COMMIT^{commit}" 2>/dev/null; then
    log "ERROR: Commit $PREV_COMMIT not found in local repository."
    exit 1
fi

# ---------- 3. Reset to previous commit ----------
log "Rolling back to commit: $PREV_COMMIT"
git reset --hard "$PREV_COMMIT"

# ---------- 4. Rebuild containers with the old code ----------
log "Rebuilding containers from rolled-back code..."
docker compose -f "$APP_DIR/docker/docker-compose.yml" up -d --build

log "Rollback finished. App restored to commit $PREV_COMMIT"