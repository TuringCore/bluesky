from hkt_probprog import CPU, BayesianScore, FeatureSignal, GaussianPrior, HKTInferenceEngine

fn recommendation_bucket(score: Float64) -> String:
    if score >= 0.70:
        return "boost"
    elif score >= 0.50:
        return "blend"
    return "explore"

fn main() raises:
    let engine = HKTInferenceEngine[CPU]()

    var feed_score = BayesianScore[FeatureSignal](
        GaussianPrior(mu=0.45, sigma=0.25),
        evidence_weight=0.0,
    )

    print("target:", engine.target_label())
    print("initial_posterior:", feed_score.posterior_mean())

    # Instrument each evidence update so contributors can reason about behavior.
    feed_score = engine.observe(feed_score, observed=0.92, confidence=0.70)
    print("event: like_author posterior:", feed_score.posterior_mean())

    feed_score = engine.observe(feed_score, observed=0.80, confidence=0.55)
    print("event: long_dwell posterior:", feed_score.posterior_mean())

    feed_score = engine.observe(feed_score, observed=0.20, confidence=0.35)
    print("event: mute_topic posterior:", feed_score.posterior_mean())

    let posterior = feed_score.posterior_mean()
    print("final_posterior:", posterior)
    print("ranking_action:", recommendation_bucket(posterior))

    # This marks the compile seam where typed model logic lowers to a target kernel.
    print(engine.compile_kernel(feed_score))

