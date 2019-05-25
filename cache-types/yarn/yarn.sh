#!/usr/bin/env bash
set -e

cache_version="1"
yarn_hash=$(md5sum yarn.lock | awk '{ print $1 }')

echo "v$cache_version-$yarn_hash" > .cache_key

if [[ -z "${PLUGIN_CACHE_DOWNLOAD}" ]]; then
  CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
    CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
    CACHE_LOCAL_DIR="node_modules" \
    AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
    /usr/local/rust-cache
else
  CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
    CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
    CACHE_LOCAL_DIR="node_modules" \
    CACHE_DOWNLOAD=1 \
    AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
    /usr/local/rust-cache
fi


rm .cache_key