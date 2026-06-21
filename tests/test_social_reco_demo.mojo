from contributor_signals import apply_like_author, apply_long_dwell, apply_mute_topic
from hkt_probprog import CPU, BayesianScore, FeatureSignal, GaussianPrior, HKTInferenceEngine

fn assert_close(lhs: Float64, rhs: Float64, eps: Float64 = 1e-9) raises:
    let diff = lhs - rhs
    if diff > eps or diff < -eps:
        raise Error("assert_close failed")

fn main() raises:
    let engine = HKTInferenceEngine[CPU]()
    var score = BayesianScore[FeatureSignal](
        GaussianPrior(mu=0.45, sigma=0.25),
        evidence_weight=0.0,
    )

    score = apply_like_author(engine, score)
    score = apply_long_dwell(engine, score)
    score = apply_mute_topic(engine, score)

    let expected_mean = (0.45 + (0.92 * 0.70) + (0.80 * 0.55) + (0.20 * 0.35)) / (1.0 + 1.60)
    assert_close(score.posterior_mean(), expected_mean)

    print("ok: test_social_reco_demo")
