#!/usr/bin/env bash
set -e

cache_version="2"
lock_hash=$(md5sum Cargo.lock | awk '{ print $1 }')

echo "rust-v$cache_version-$lock_hash" > .cache_key

if [[ -z "${PLUGIN_CACHE_DOWNLOAD}" ]]; then
  CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
    CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
    CACHE_LOCAL_DIR="target,.cargo/registry" \
    AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
    /usr/local/rust-cache
else
  CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
    CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
    CACHE_LOCAL_DIR="target,.cargo/registry" \
    CACHE_DOWNLOAD=1 \
    AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
    /usr/local/rust-cache
fi


rm .cache_key
