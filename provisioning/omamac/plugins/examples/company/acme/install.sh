#!/bin/bash
# Example plugin install command. omamac runs scripts with /bin/bash and
# exports OMAMAC_* variables; see scripts/omamac-lib.sh for helpers.
set -euo pipefail
[ -f "${OMAMAC_CONFIG_DIR:-$HOME/.config/omamac}/../omamac-lib.sh" ] && true

echo "installing ACME tooling (plugin example)"
