# ari-lint Roadmap

Current status: skeleton initialized / Ari source skeleton started / internal
model skeleton started / no real lint implementation yet.

## Split Roadmap

- [x] Initialize repo skeleton.
- [ ] Migrate `docs/lint` from `ari-foundry/ari`; `docs/migration.md` tracks
      the documentation migration plan.
- [ ] Plan Ari-language reimplementation with behavior parity against current
      `tools/lint`; `docs/dev/ari-implementation-plan.md` tracks the staged
      implementation plan.
- [x] Start Ari source skeleton as the first step toward Ari-language
      implementation; real rule implementation, CLI parsing, diagnostics,
      compiler invocation, and tests remain future work.
- [x] Start internal data model skeleton as preparatory Ari source work only;
      rule implementation, CLI parsing, diagnostics output, config parsing,
      compiler invocation, implementation tests, and implementation CI remain
      future work.
- [ ] Plan parity testing against current `tools/lint`;
      `docs/dev/parity-test-plan.md` tracks the future fixture and golden
      output strategy, but parity tests and CI parity jobs are not implemented.
- [ ] Wire standalone build.
- [ ] Wire standalone tests.
- [ ] Define release and compatibility policy after inspecting Ari releases and
      Ari tags; define `ari-lint` compatibility only after Ari-language source
      and standalone tests exist.
- [ ] Move implementation toward Ari-language code when feasible, after the
      documented plan has enough verified compiler/toolchain support.
- [ ] Update Ari Foundry portal after repo is usable.

These steps are planned split work. Except for the initial skeleton, they are
not complete yet.
