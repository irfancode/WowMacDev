#!/bin/bash
set -euo pipefail
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
echo "firewall enabled"
