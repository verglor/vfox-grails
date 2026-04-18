#!/usr/bin/env bash
set -euo pipefail

echo "=== Unit tests ==="
busted --output=TAP test/unit/

echo "=== Integration tests ==="
eval "$(vfox activate bash)"
bats test/integration/