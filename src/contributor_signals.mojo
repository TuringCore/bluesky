from contracts import apply_signal_update
from hkt_probprog import BayesianScore, ComputeTarget, FeatureSignal, HKTInferenceEngine

# Contributor-owned signal module examples.
fn apply_like_author[T: ComputeTarget](
    engine: HKTInferenceEngine[T],
    score: BayesianScore[FeatureSignal],
) raises -> BayesianScore[FeatureSignal]:
    return apply_signal_update(engine, score, "like_author", 0.92, 0.70)

fn apply_long_dwell[T: ComputeTarget](
    engine: HKTInferenceEngine[T],
    score: BayesianScore[FeatureSignal],
) raises -> BayesianScore[FeatureSignal]:
    return apply_signal_update(engine, score, "long_dwell", 0.80, 0.55)

fn apply_mute_topic[T: ComputeTarget](
    engine: HKTInferenceEngine[T],
    score: BayesianScore[FeatureSignal],
) raises -> BayesianScore[FeatureSignal]:
    return apply_signal_update(engine, score, "mute_topic", 0.20, 0.35)

