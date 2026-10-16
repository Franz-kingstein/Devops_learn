#!/usr/bin/env bash
# deploy.sh - runs ON THE AZURE VM (invoked by Jenkins over SSH)
# Purpose: pull latest code into /opt/app, remember the previous commit,
#          rebuild and restart containers with docker compose.
set -euo pipefail

APP_DIR="/opt/app"
REPO_URL="https://github.com/Franz-kingstein/Devops_learn.git"
BRANCH="main"
APP_VERSION="${APP_VERSION:-1.0.0}"

log() { echo "[deploy] $*"; }

cd "$APP_DIR"

# ---------- 1. Clone on first deploy, pull afterwards ----------
if [ ! -d "$APP_DIR/.git" ]; then
    log "First deploy: cloning repository..."
    # cloud-init creates VERSION/GITHUB_REPO markers; remove them so
    # git clone works into the existing (non-empty) /opt/app directory
    rm -f "$APP_DIR/VERSION" "$APP_DIR/GITHUB_REPO"
    git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
else
    # ---------- 2. Save current commit for rollback ----------
    PREV_COMMIT="$(git rev-parse HEAD)"
    echo "$PREV_COMMIT" > "$APP_DIR/.prev_commit"
    log "Saved previous commit: $PREV_COMMIT"

    log "Pulling latest changes from $BRANCH..."
    git fetch origin
    git reset --hard "origin/$BRANCH"
fi

log "Now at commit: $(git rev-parse --short HEAD)"

# ---------- 3. Build and start containers ----------
log "Running docker compose up -d --build ..."
docker compose -f "$APP_DIR/docker/docker-compose.yml" \
    --project-directory "$APP_DIR" \
    up -d --build

log "Deploy finished. Current version: $APP_VERSION"