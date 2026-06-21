# Contributor and Maintainer Contract

This document defines the implementation boundary for collaborative changes in `/bluesky`.

## Contract surface

- Maintainers own `src/contracts.mojo`.
- Contributors extend `src/contributor_signals.mojo` (or additional files in `src/`).
- Contributors must call `apply_signal_update(...)` for all new event updates.
- Contributors must keep `observed` and `confidence` values in `[0, 1]`.
- Contributors must add deterministic tests for changed scoring behavior.

## Why this contract exists

- Preserves typed integration with `/turing` (`BayesianScore[FeatureSignal]`).
- Centralizes validation and instrumentation in one maintained boundary.
- Keeps review scope small: maintainers verify interfaces, contributors iterate on signals.

## Minimal review checklist

- Signal module compiles against the shared contract.
- Tests include expected posterior checks.
- RFC is added when ranking semantics change.

