#!/usr/bin/env bash
# Runs the sample project's tests on one target through the CLI, the way
# `haxelib run dropecho.testing` does, and checks that the tests really ran.
#
# Usage: test/e2e/run.sh <target> [expected assertions]
set -euo pipefail

target="$1"
expected="${2:-3}"
repo="$(cd "$(dirname "$0")/../.." && pwd)"
project="$repo/test/e2e/sample"
log="$(mktemp)"

cd "$project"
printf '{"hxml": "%s.hxml"}\n' "$target" > .dropecho.testing.json

# haxelib sets HAXELIB_RUN=1 and passes the caller's directory as the last argument.
status=0
HAXELIB_RUN=1 haxe --class-path "$repo" --run tools.Run "$project/" 2>&1 | tee "$log" || status=$?
rm -f .dropecho.testing.json

if [ "$status" -ne 0 ]; then
	echo "e2e: $target tests failed (exit $status)" >&2
	exit "$status"
fi

# A passing run must report the expected number of assertions; zero means nothing ran.
if ! grep -q "^results: ALL TESTS OK (assertions: $expected," "$log"; then
	echo "e2e: $target passed but did not report $expected assertions" >&2
	exit 1
fi
echo "e2e: $target ran $expected assertions and passed"
