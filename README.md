# Bluesky Recommendation Service Demo

`/bluesky` is a small application repo that imports `/turing` and shows how an organization can operate a typed Bayesian recommendation component without letting model complexity spread across the whole serving stack.

The point of this repo is not to present a full product architecture. It is to show a practical seam:

- `/turing` owns the reusable probabilistic programming library,
- `/bluesky` owns product-facing ranking behavior,
- `src/contracts.mojo` is the reviewed boundary between contributor code and deployment code,
- `compile_kernel(...)` marks where the same typed model can be lowered for CPU or GPU targets.

That operating model matters in large systems where many teams add ranking ideas over time and Bayesian updates can otherwise become hard to reason about.

## What this demonstrates

- Importing shared Bayesian inference primitives from `/turing`.
- Keeping contributor-authored signal logic modular and reviewable.
- Routing all evidence updates through a maintainer-owned contract.
- Using the Mojo compile system to make the CPU/GPU build target explicit at compile time.
- Preserving a simple operational path from local test to staged deployment.

## Repository layout and ownership

- `src/contracts.mojo`: platform-maintained contract for validation, instrumentation, and integration with `/turing`.
- `src/contributor_signals.mojo`: ML-engineer extension point for new or revised ranking signals.
- `src/main.mojo`: CPU demo entrypoint for local validation and service-style smoke testing.
- `src/main_gpu.mojo`: GPU-target demo entrypoint using the same typed model graph.
- `tests/test_social_reco_demo.mojo`: deterministic posterior validation for scoring changes.
- `docs/contributor-contract.md`: explicit contributor/maintainer boundary.
- `docs/rfcs/`: design notes for changes that alter ranking semantics.
- `.github/CODEOWNERS`: review routing for contract, test, and application ownership.

## How to operate this inside an organization

Treat `/bluesky` as the application repository that sits one layer above `/turing`.

- The **ML engineering** team owns signal proposals, evidence calibration, and ranking behavior checks.
- The **platform engineering** team owns the compile seam, target-specific builds, packaging, runtime policy, and deployment automation.
- Product or applied-science reviewers sign off on policy changes through deterministic tests and lightweight RFCs.

This split was selected for a practical reason: probabilistic systems become fragile when the same person has to change model semantics, target compilation, and runtime deployment mechanics in one diff. Separating those concerns keeps failures localized.

## ML engineer workflow

ML engineers should be able to add ranking ideas without owning the entire build and deployment surface.

1. Add or revise a signal in `src/contributor_signals.mojo`.
2. Call `apply_signal_update(...)` from `src/contracts.mojo` for every new event update.
3. Keep `observed` and `confidence` in `[0, 1]` so calibration stays within the maintained contract.
4. Add deterministic expected-posterior checks in `tests/test_social_reco_demo.mojo`.
5. If the change affects ranking semantics, add a short RFC in `docs/rfcs/` describing the intended effect on feed behavior.

In a production setting, this usually maps to an ML workflow like:

- evaluate a new signal offline against replay data,
- encode the signal in Mojo,
- validate posterior behavior deterministically,
- ship the change behind a staged rollout.

This repo keeps that workflow small on purpose. Contributors change signal modules; maintainers keep the seam stable.

## Platform engineer workflow

Platform engineers maintain the boundary where application code imports `/turing`, gets instrumented, and is compiled for a serving target.

### Compile seam responsibilities

Platform engineers should own:

- `src/contracts.mojo`, because it centralizes validation and logging behavior,
- the `/turing` version or monorepo dependency boundary,
- CPU and GPU build definitions,
- CI checks that run the deterministic tests before promotion,
- runtime packaging and deployment policy.

In this demo, the compile seam is visible in `engine.compile_kernel(feed_score)`. In a larger service, that seam is where platform teams can:

- pin the `/turing` library revision,
- select `HKTInferenceEngine[CPU]` or `HKTInferenceEngine[GPU]`,
- emit target-specific binaries or container images,
- attach deployment metadata such as model version, feature-set version, and release channel.

### Why the seam is organized this way

- A maintainer-owned contract prevents ad hoc update logic from bypassing validation.
- The typed interface from `/turing` keeps signal composition narrow and reviewable.
- Mojo's compile-time specialization makes the serving target explicit, which reduces ambiguity in release pipelines.
- Deterministic tests catch semantic ranking drift before runtime metrics do.

## Recommended cloud deployment pattern

For an internal organization, a practical production pattern is to package `/bluesky` as a small ranking component and run it inside a standard inference platform.

### AWS example

- **Source control and CI:** GitHub Enterprise or CodeCommit with GitHub Actions / CodeBuild.
- **Artifact storage:** Amazon ECR for OCI images and Amazon S3 for replay fixtures, scoring baselines, and release manifests.
- **Serving cluster:** Amazon EKS.
- **CPU pools:** EKS managed node groups for standard low-latency ranking paths.
- **GPU pools:** Separate EKS node groups on GPU-capable instances such as `g5` or `g6` when the Mojo GPU target is used.
- **Deployment controller:** Argo CD or Flux for environment promotion.
- **Observability:** CloudWatch logs, Prometheus, and Grafana for posterior summaries, request latency, and rollout health.
- **Secrets and access:** IAM roles for service accounts plus AWS Secrets Manager or Parameter Store.

### Concrete internal service topology

One practical way to run this inside a company is:

1. Product events land in **Kafka or Amazon Kinesis**.
2. Batch feature generation or replay analysis runs in **SageMaker Processing**, **AWS Batch**, or an internal Spark platform.
3. Curated replay datasets and calibration snapshots are written to **Amazon S3**.
4. CI compiles `/bluesky` against the pinned `/turing` revision and publishes a CPU or GPU container to **Amazon ECR**.
5. The serving binary runs in **Amazon EKS** behind an internal **Application Load Balancer** or as a sidecar/service consumed by a larger feed-ranking tier.
6. **Horizontal Pod Autoscaler** scales CPU deployments on latency or QPS, while GPU deployments scale from a separate node group with stricter admission control.
7. Runtime metrics and posterior summaries flow into **CloudWatch**, **Prometheus**, and **Grafana** for rollout decisions.

This topology was selected because it cleanly separates offline experimentation from online serving while keeping the compile seam controlled by platform engineering.

Recommended operational split:

- ML engineers merge signal changes after offline validation and deterministic tests.
- Platform engineers build two release artifacts when needed: a CPU image from `src/main.mojo` and a GPU image from `src/main_gpu.mojo`.
- Staging deploys first, using replay traffic or shadow traffic to compare posterior distributions and bucket actions.
- Promotion to production happens only after contract checks, tests, and observability thresholds pass.

In most organizations, the CPU artifact is the default production path and the GPU artifact is promoted only for throughput-sensitive workloads where the added runtime complexity is justified.

### Equivalent patterns on GCP or Azure

- **GCP:** Artifact Registry + GKE + Cloud Storage + Cloud Monitoring.
- **Azure:** Azure Container Registry + AKS + Blob Storage + Azure Monitor.

The important part is not the cloud vendor. It is preserving the compile seam so the same typed scoring logic is promoted through consistent build targets.

## Suggested internal repository practices

These practices make the repo easier to maintain across multiple teams:

- Keep all contributor-authored updates behind `src/contracts.mojo`.
- Require deterministic posterior tests for every signal change.
- Use `.github/CODEOWNERS` so platform owners must review contract and deployment-affecting edits.
- Use `docs/rfcs/` only for changes that alter ranking semantics, thresholds, or rollout assumptions.
- Pin the `/turing` dependency at a reviewed revision during release windows.

These choices were selected because they reduce the blast radius of changes in probabilistic systems. When inference code, deployment code, and product policy are all mixed together, failures are difficult to attribute. This repo keeps them separate enough to operate reliably.

## Sample contributor-to-maintainer flow

1. An ML engineer proposes a new signal module in `src/contributor_signals.mojo`.
2. The signal routes through `apply_signal_update(...)` in `src/contracts.mojo`.
3. Deterministic posterior expectations are added to `tests/test_social_reco_demo.mojo`.
4. If the ranking interpretation changes, the engineer adds an RFC in `docs/rfcs/`.
5. A platform engineer reviews the contract boundary, `/turing` compatibility, and build impact.
6. CI compiles the CPU path, runs tests, and optionally produces a GPU-target artifact.
7. The service is promoted through staging before production rollout.

This makes the contract between contributors and maintainers explicit without turning the demo into a full platform framework.

## Run and test locally (CPU)

Run from `/Users/jrule/git/turingcore/bluesky`:

```zsh
mojo -I ../turing/src -I src src/main.mojo
mojo -I ../turing/src -I src tests/test_social_reco_demo.mojo
```

## Compile and run on a GPU target

The GPU demo uses `HKTInferenceEngine[GPU]` in `src/main_gpu.mojo`.

```zsh
mojo -I ../turing/src -I src src/main_gpu.mojo
```

If your Mojo toolchain or deployment image requires additional GPU runtime flags, append them to the same command in local development and mirror those settings in your CI build definition.

## Practical application context

The same operating model is useful anywhere a team needs to control uncertainty-aware scoring in a system with many contributors:

- **Finance:** risk ranking, fraud suspicion updates, and portfolio prioritization.
- **Healthcare:** triage queues, utilization forecasting, and confidence-weighted clinical support.
- **Operations:** incident routing, inventory prioritization, and demand balancing.
- **Recommendations:** feed ranking, candidate blending, and exploration policies.

## Related example

For the companion application example, see:

https://github.com/TuringCore/bluesky
