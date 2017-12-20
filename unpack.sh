#!/bin/bash -e

. ./buildpack_vars.sh

BUILDPACK_BUILD_DIR="$SRC_DIR/buildpack-build"
rm -rf "$BUILDPACK_BUILD_DIR"
mkdir -p "$BUILDPACK_BUILD_DIR"

unzip "$ZIP_FILE" -d "$BUILDPACK_BUILD_DIR"
