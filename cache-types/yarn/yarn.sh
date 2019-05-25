#!/usr/bin/env bash
set -e

cache_version="2"
yarn_hash=$(md5sum yarn.lock | awk '{ print $1 }')

echo "yarn-v$cache_version-$yarn_hash" > .cache_key

echo "cache=.cache" >> .npmrc

if [[ -z "${PLUGIN_CACHE_DOWNLOAD}" ]]; then
  CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
    CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
    CACHE_LOCAL_DIR=".cache" \
    AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
    /usr/local/rust-cache
else
  CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
    CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
    CACHE_LOCAL_DIR=".cache" \
    CACHE_DOWNLOAD=1 \
    AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
    /usr/local/rust-cache
fi


rm .cache_key
