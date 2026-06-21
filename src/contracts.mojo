from hkt_probprog import BayesianScore, ComputeTarget, FeatureSignal, HKTInferenceEngine

fn check_probability(name: String, value: Float64) raises:
    if value < 0.0 or value > 1.0:
        raise Error(name + " must be in [0, 1]")

# Maintainer-owned contract: contributor modules call this helper to apply updates.
fn apply_signal_update[T: ComputeTarget](
    engine: HKTInferenceEngine[T],
    score: BayesianScore[FeatureSignal],
    signal_name: String,
    observed: Float64,
    confidence: Float64,
) raises -> BayesianScore[FeatureSignal]:
    check_probability("observed", observed)
    check_probability("confidence", confidence)

    let updated = engine.observe(score, observed=observed, confidence=confidence)
    print("event:", signal_name, "posterior:", updated.posterior_mean())
    return updated

