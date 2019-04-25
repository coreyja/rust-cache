#!/usr/bin/env bash

CACHE_S3_PATH="coreyja/test1" \
  CACHE_BUCKET="cache.dokku.coreyja" \
  CACHE_LOCAL_DIR="vendor/bundle" \
  /usr/local/rust-cache
