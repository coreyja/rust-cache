#!/usr/bin/env bash

md5sum Gemfile.lock > .cache_key

CACHE_S3_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME" \
  CACHE_BUCKET=$PLUGIN_CACHE_BUCKET \
  CACHE_LOCAL_DIR="vendor/bundle" \
  /usr/local/rust-cache
