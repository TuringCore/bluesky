# Contributing

Thanks for contributing to the Bluesky recommendation demo.

## Collaboration model

- Keep core probabilistic primitives in `/turing`.
- Keep Bluesky policy and product-facing behavior in this repo.
- Use `src/contracts.mojo` as the maintainer-owned boundary.
- Implement or extend signal modules in `src/contributor_signals.mojo`.
- Open an RFC in `docs/rfcs/` for non-trivial ranking behavior changes.

## Contributor workflow

1. Add or modify a signal function in `src/contributor_signals.mojo`.
2. Route updates through `apply_signal_update(...)` in `src/contracts.mojo`.
3. Add deterministic expected-value checks in `tests/test_social_reco_demo.mojo`.
4. Request review from CODEOWNERS.
5. Add an RFC if ranking semantics changed.

## Local validation (CPU)

From `/Users/jrule/git/turingcore/bluesky`:

```zsh
mojo -I ../turing/src -I src src/main.mojo
mojo -I ../turing/src -I src tests/test_social_reco_demo.mojo
```

## GPU target run

```zsh
mojo -I ../turing/src -I src src/main_gpu.mojo
```

If your environment requires extra GPU runtime flags, append them to the command above.

## PR expectations

- Include problem statement and behavior impact.
- Link to RFC when relevant.
- Keep changes scoped to one concern.
- Update tests for all scoring or policy changes.

