# Contributing

Thanks for contributing to the Bluesky recommendation demo.

## Collaboration model

- Keep core probabilistic primitives in `/turing`.
- Keep Bluesky-specific policy and instrumentation in this repo.
- Open an RFC in `docs/rfcs/` for non-trivial behavior or interface changes.

## Local validation

From `/Users/jrule/git/turingcore/bluesky`:

```zsh
mojo -I ../turing/src src/main.mojo
mojo -I ../turing/src tests/test_social_reco_demo.mojo
```

## PR expectations

- Include problem statement and behavior impact.
- Link to RFC when relevant.
- Keep changes scoped to one concern.
- Update tests for all scoring or policy changes.

