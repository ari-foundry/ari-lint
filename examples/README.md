# ari-lint Examples

The standalone CLI is wired, but this directory does not yet publish separate
Ari example programs.

Ari code examples must be based on current `ari-foundry/ari` docs, examples,
and tests.

After building with a locally selected Ari compiler, lint an Ari source file
whose syntax has been verified by that compiler:

```sh
scripts/build.sh /path/to/ari
./build/ari-lint --ari /path/to/ari path/to/source.ari
./build/ari-lint --json --ari /path/to/ari path/to/source.ari
```

These commands demonstrate the CLI boundary only; `path/to/source.ari` is a
placeholder, not an Ari-language example. See
[the feature overview](../docs/features.md) and
[configuration guide](../docs/config.md) for supported behavior.
