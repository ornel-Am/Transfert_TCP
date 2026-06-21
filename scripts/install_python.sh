#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
mkdir -p "$PROJECT_DIR/portable_python"
tar -xzf "$PROJECT_DIR/deps/linux/python-portable.tar.gz" -C "$PROJECT_DIR/portable_python" --strip-components=1
"$PROJECT_DIR/portable_python/bin/python3" -m pip install --no-index --find-links="$PROJECT_DIR/deps/wheels" pyinstaller
echo "✅ Python portable installé."
