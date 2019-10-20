#!/usr/bin/env bash
set -e

BASE_DIR="${$PLUGIN_BASE_DIR:-./}"

pushd "$BASE_DIR"
  cache_version="6"
  yarn_hash=$(md5sum yarn.lock | awk '{ print $1 }')
  yarn_cache_location="cache/yarn"

  echo "yarn-v$cache_version-$yarn_hash" > .cache_key
  echo "--cache-folder $yarn_cache_location" >> .yarnrc

  if [[ -z "${PLUGIN_CACHE_DOWNLOAD}" ]]; then
    CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
      CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
      CACHE_LOCAL_DIR="$yarn_cache_location" \
      AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
      AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
      /usr/local/rust-cache
  else
    CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
      CACHE_BUCKET="$PLUGIN_CACHE_BUCKET" \
      CACHE_LOCAL_DIR="$yarn_cache_location" \
      CACHE_DOWNLOAD=1 \
      AWS_ACCESS_KEY_ID="$PLUGIN_AWS_ACCESS_KEY_ID" \
      AWS_SECRET_ACCESS_KEY="$PLUGIN_AWS_SECRET_ACCESS_KEY" \
      /usr/local/rust-cache
  fi
popd
