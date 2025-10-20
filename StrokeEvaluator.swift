import Foundation

protocol AttemptEvaluator {
    func evaluate(user: [StrokePath], ideal: [StrokePath]) -> PracticeScore
}

struct DefaultAttemptEvaluator: AttemptEvaluator {
    func evaluate(user: [StrokePath], ideal: [StrokePath]) -> PracticeScore {
        let orderAccuracy = 1.0 - Double(abs(user.count - ideal.count)) / Double(max(ideal.count, 1))
        let shapeSimilarity = min(orderAccuracy + 0.1, 1.0)
        return PracticeScore(orderAccuracy: orderAccuracy, shapeSimilarity: shapeSimilarity)
    }
}
