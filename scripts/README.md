# ari-lint Scripts

This directory contains lightweight repository helper scripts.

`check.sh` verifies repository shape and fixture invariants only. It does not
run the Ari compiler, invoke `ari --check`, execute `tools/lint`, run parity
checks, run CLI tests, or compare golden files.
