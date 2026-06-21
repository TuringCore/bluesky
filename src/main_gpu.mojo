from contributor_signals import apply_like_author, apply_long_dwell, apply_mute_topic
from hkt_probprog import BayesianScore, FeatureSignal, GPU, GaussianPrior, HKTInferenceEngine

fn recommendation_bucket(score: Float64) -> String:
    if score >= 0.70:
        return "boost"
    elif score >= 0.50:
        return "blend"
    return "explore"

fn main() raises:
    let engine = HKTInferenceEngine[GPU]()

    var feed_score = BayesianScore[FeatureSignal](
        GaussianPrior(mu=0.45, sigma=0.25),
        evidence_weight=0.0,
    )

    print("target:", engine.target_label())
    print("initial_posterior:", feed_score.posterior_mean())

    feed_score = apply_like_author(engine, feed_score)
    feed_score = apply_long_dwell(engine, feed_score)
    feed_score = apply_mute_topic(engine, feed_score)

    let posterior = feed_score.posterior_mean()
    print("final_posterior:", posterior)
    print("ranking_action:", recommendation_bucket(posterior))

    # GPU-target compile seam using the same typed model graph.
    print(engine.compile_kernel(feed_score))

