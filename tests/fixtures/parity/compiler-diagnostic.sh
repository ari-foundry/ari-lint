#!/bin/sh

set -eu

expected_source="tests/fixtures/trailing-whitespace/trailing-spaces.ari"

if [ "$#" -ne 2 ] || [ "$1" != "$expected_source" ] || [ "$2" != "--check" ]; then
  printf '%s\n' "unexpected compiler argv" >&2
  exit 97
fi

printf '%s\n' "ari: error[E1]: fake.ari:2:3: compiler first" >&2
exit 7
