# Bluesky Recommendation Demo

`/bluesky` is an application demo that imports `/turing` and applies conservative Bayesian scoring to a simple social feed recommendation flow.

## What this demonstrates

- Importing shared probabilistic library code from `/turing`.
- Instrumenting evidence updates so behavior is easy to review.
- Calling the library compile seam (`compile_kernel`) to show target-aware lowering.
- Keeping app logic separate from core inference primitives.

## Repository layout

- `src/main.mojo`: demo app entrypoint.
- `tests/test_social_reco_demo.mojo`: deterministic posterior validation.
- `docs/rfcs/`: lightweight design proposals for larger changes.
- `.github/CODEOWNERS`: review ownership for multi-contributor scaling.

## Why this layout works for multiple contributors

- **Clear boundaries:** `/turing` owns inference primitives; `/bluesky` owns product behavior.
- **Small review units:** contributors can edit ranking policy without touching core math internals.
- **Deterministic checks:** tests keep posterior math reproducible during rapid iteration.
- **RFC-lite process:** larger behavior shifts are documented before implementation.
- **Ownership mapping:** CODEOWNERS routes reviews to maintainers closest to each area.

## Run locally

Run commands from `/Users/jrule/git/turingcore/bluesky`:

```zsh
mojo -I ../turing/src src/main.mojo
mojo -I ../turing/src tests/test_social_reco_demo.mojo
```

## Practical application context

The same contributor workflow can be reused for production-oriented systems in:

- finance (portfolio/risk ranking),
- healthcare (priority scoring under uncertainty),
- operations (queue and incident prioritization),
- recommendations (candidate ranking and exploration decisions).

