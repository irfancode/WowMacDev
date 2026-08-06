#!/bin/bash
set -euo pipefail
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
exit 0
