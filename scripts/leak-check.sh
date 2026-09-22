#!/usr/bin/env bash
# Pre-publish leak gate. Exits non-zero if any file in the repo matches a
# pattern that should never ship publicly. Run from the repo root before every
# push. Private terms live in .private-patterns (gitignored) so this script
# never names what it guards.
set -euo pipefail
cd "$(dirname "$0")/.."

# Generic patterns only — anything that names your private tools, company,
# people, or paths goes in .private-patterns (gitignored, one ERE per line).
patterns=(
  '/home/' '~/[a-z]+/' '@gmail' '#[0-9]{3,}'
)

extra="${PRIVATE_PATTERNS_FILE:-.private-patterns}"
if [ -f "$extra" ]; then
  while IFS= read -r p; do [ -n "$p" ] && patterns+=("$p"); done < "$extra"
fi

fail=0
for p in "${patterns[@]}"; do
  # command grep: bypass any aliased grep that skips ignored/binary files.
  if hits=$(command grep -rniE --exclude-dir=.git --exclude=leak-check.sh --exclude=LICENSE --exclude="$(basename "$extra")" -- "$p" . ); then
    echo "LEAK [$p]"; echo "$hits" | sed 's/^/  /'; fail=1
  fi
done

if [ "$fail" -eq 0 ]; then echo "leak-check: clean (${#patterns[@]} patterns)"; fi
exit "$fail"
