#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

make clean
make -j2 WITH_GDAL=
make -j2 WITH_GDAL=1

output=$(./bin/2D-DWE --config /tmp/dwe-build-mode-check-missing.txt 2>&1 || true)
if grep -q 'needs GDAL' <<<"$output"; then
    echo 'GDAL build reused dependency-free objects' >&2
    exit 1
fi

make -j2 WITH_GDAL=
output=$(./bin/2D-DWE --config /tmp/dwe-build-mode-check-missing.txt 2>&1 || true)
if ! grep -q 'needs GDAL' <<<"$output"; then
    echo 'dependency-free build reused GDAL objects' >&2
    exit 1
fi

echo 'Build-mode switching produced the requested executable each time.'
