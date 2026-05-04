#!/usr/bin/env bash
# Build and launch the Claudet desktop pet.
# Claudet masaüstü pet'ini derle ve başlat.
#
# We build into /tmp because Spotlight/iCloud-managed Desktop folders
# can throw disk I/O errors against Swift's sqlite-backed build cache.
# /tmp altında derliyoruz çünkü Spotlight/iCloud-yönetimli Desktop
# klasörleri Swift'in sqlite tabanlı build cache'ine karşı disk I/O
# hataları verebiliyor.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
build_dir="${CLAUDET_BUILD_DIR:-/tmp/claudet-build}"

swift build -c release --build-path "$build_dir"
exec "$build_dir/release/claudet"
