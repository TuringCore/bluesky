# Bluesky Recommendation Demo

`/bluesky` is an application demo that imports `/turing` and applies Bayesian scoring to a simple social feed recommendation flow.

## What this demonstrates

- Importing shared probabilistic library code from `/turing`.
- Instrumenting evidence updates so behavior is easy to review.
- Calling the library compile seam (`compile_kernel`) to show target-aware lowering.
- Keeping app policy logic separate from shared inference primitives.

## Repository layout

- `src/contracts.mojo`: maintainer-owned contract for applying scored events.
- `src/contributor_signals.mojo`: contributor-owned signal modules using the contract.
- `src/main.mojo`: CPU demo entrypoint.
- `src/main_gpu.mojo`: GPU-target demo entrypoint.
- `tests/test_social_reco_demo.mojo`: deterministic posterior validation.
- `docs/contributor-contract.md`: explicit contributor/maintainer contract.
- `docs/rfcs/`: lightweight design proposals for larger changes.
- `.github/CODEOWNERS`: review ownership for multi-contributor scaling.

## Sample contributor flow

1. A contributor proposes a new signal module in `src/contributor_signals.mojo` (or a new file under `src/`).
2. The module must call `apply_signal_update(...)` from `src/contracts.mojo`.
3. A maintainer reviews contract compliance (typed signal, value bounds, instrumentation output).
4. Contributor adds deterministic test coverage in `tests/test_social_reco_demo.mojo`.
5. If behavior meaningfully changes ranking policy, contributor adds an RFC in `docs/rfcs/`.

This keeps the contributor-maintainer contract explicit: contributors own event definitions, maintainers own interface and validation boundaries.

## Run and test (CPU)

Run from `/Users/jrule/git/turingcore/bluesky`:

```zsh
mojo -I ../turing/src -I src src/main.mojo
mojo -I ../turing/src -I src tests/test_social_reco_demo.mojo
```

## Compile and run on GPU target

The GPU demo uses `HKTInferenceEngine[GPU]` in `src/main_gpu.mojo`.

```zsh
mojo -I ../turing/src -I src src/main_gpu.mojo
```

If your local Mojo toolchain includes additional GPU runtime flags, pass them to the same command above.

## Practical application context

The same contributor workflow can be reused for production-oriented systems in:

- finance (portfolio/risk ranking),
- healthcare (priority scoring under uncertainty),
- operations (queue and incident prioritization),
- recommendations (candidate ranking and exploration decisions).
