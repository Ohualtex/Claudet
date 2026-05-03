#!/usr/bin/env bash
# Build and launch the Claudet desktop pet.
#
# We build into /tmp because Spotlight/iCloud-managed Desktop folders
# can throw disk I/O errors against Swift's sqlite-backed build cache.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
build_dir="${CLAUDET_BUILD_DIR:-/tmp/claudet-build}"

swift build -c release --build-path "$build_dir"
exec "$build_dir/release/claudet"
