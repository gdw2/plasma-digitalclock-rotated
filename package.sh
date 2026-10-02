#!/usr/bin/env bash
# Build the distributable widget archive from the package sources.
set -euo pipefail
cd "$(dirname "$0")"

id="org.kde.plasma.digitalclock.rotated"
outdir="build"
mkdir -p "$outdir"

tar -czf "$outdir/$id.plasmoid" metadata.json contents
cp "$outdir/$id.plasmoid" "$outdir/$id.tar.gz"

echo "Wrote:"
echo "  $outdir/$id.plasmoid"
echo "  $outdir/$id.tar.gz"
