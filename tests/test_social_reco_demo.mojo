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

    score = engine.observe(score, observed=0.92, confidence=0.70)
    score = engine.observe(score, observed=0.80, confidence=0.55)
    score = engine.observe(score, observed=0.20, confidence=0.35)

    let expected_mean = (0.45 + (0.92 * 0.70) + (0.80 * 0.55) + (0.20 * 0.35)) / (1.0 + 1.60)
    assert_close(score.posterior_mean(), expected_mean)

    print("ok: test_social_reco_demo")

