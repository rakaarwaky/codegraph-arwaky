#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$BASE_DIR/codegraph"
DIST_DIR="$BASE_DIR/dist"

echo ">>> Creating dist directory..."
mkdir -p "$DIST_DIR"

echo ">>> Building CodeGraph from source..."
cd "$REPO_DIR"

echo ">>> Installing dependencies..."
npm ci || npm install

echo ">>> Building Rust kernel..."
if [ -d "codegraph-kernel" ]; then
    npm run build:kernel || (cd codegraph-kernel && cargo build --release)
fi

echo ">>> Compiling TypeScript..."
npm run build

echo ">>> Staging build output to dist/..."
rm -rf "$DIST_DIR/*"
cp -r dist/* "$DIST_DIR/"
cp package.json "$DIST_DIR/"
if [ -d "node_modules" ]; then
    cp -r node_modules "$DIST_DIR/"
fi

echo ">>> Setting permissions..."
chmod +x "$DIST_DIR/bin/codegraph.js" 2>/dev/null || true

echo ">>> Done! CodeGraph built into $DIST_DIR"
