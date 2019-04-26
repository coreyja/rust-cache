#!/usr/bin/env bash
set -e

cache_version="1"
gemfile_hash=$(md5sum Gemfile.lock | awk '{ print $1 }')

echo "v$cache_version-$gemfile_hash" > .cache_key

CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/" \
  CACHE_BUCKET=$PLUGIN_CACHE_BUCKET \
  CACHE_LOCAL_DIR="vendor/bundle" \
  /usr/local/rust-cache

rm .cache_key
