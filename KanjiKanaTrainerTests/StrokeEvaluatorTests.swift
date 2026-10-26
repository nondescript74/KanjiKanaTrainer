import Testing
@testable import KanjiKanaTrainer

/// Checks the scorer the way a teacher would: the right strokes, in the right
/// order and direction, roughly in the right place — at any size.
struct StrokeEvaluatorTests {

    private let evaluator = DefaultAttemptEvaluator()

    /// 十 as two reference strokes on the 0–1 grid: across, then down.
    private let ten: [StrokePath] = [
        line(from: (0.1, 0.5), to: (0.9, 0.5)),
        line(from: (0.5, 0.1), to: (0.5, 0.9)),
    ]

    /// The same character drawn on a 500-point canvas, as PencilKit would give it.
    private func onCanvas(_ strokes: [StrokePath], scale: Float = 500, offset: Float = 20) -> [StrokePath] {
        strokes.map { StrokePath(points: $0.points.map { StrokePoint(x: $0.x * scale + offset, y: $0.y * scale + offset, t: $0.t) }) }
    }

    @Test func aCorrectAttemptScoresHighAtAnySize() {
        let score = evaluator.evaluate(user: onCanvas(ten), ideal: ten)
        #expect(score.total > 0.95)
    }

    @Test func referenceOnTheHanziGridScoresTheSameAsOnTheUnitGrid() {
        let grid1024 = onCanvas(ten, scale: 1024, offset: 0)
        let a = evaluator.evaluate(user: onCanvas(ten), ideal: ten)
        let b = evaluator.evaluate(user: onCanvas(ten), ideal: grid1024)
        #expect(abs(a.total - b.total) < 0.01)
    }

    @Test func strokesInTheWrongOrderLoseOrderAccuracy() {
        let swapped = onCanvas([ten[1], ten[0]])
        let score = evaluator.evaluate(user: swapped, ideal: ten)
        #expect(score.orderAccuracy < 0.5)
    }

    @Test func aStrokeWrittenBackwardsCostsHalfItsOrderCredit() {
        let backwards = onCanvas([ten[0], StrokePath(points: ten[1].points.reversed())])
        let score = evaluator.evaluate(user: backwards, ideal: ten)
        #expect(abs(score.orderAccuracy - 0.75) < 0.01)
    }

    @Test func aMissingStrokeLowersTheScore() {
        let score = evaluator.evaluate(user: onCanvas([ten[0]]), ideal: ten)
        #expect(score.total < 0.5)
    }

    @Test func nothingDrawnScoresZero() {
        let score = evaluator.evaluate(user: [], ideal: ten)
        #expect(score.total == 0)
    }
}

private func line(from a: (Float, Float), to b: (Float, Float), samples: Int = 8) -> StrokePath {
    StrokePath(points: (0..<samples).map { i in
        let t = Float(i) / Float(samples - 1)
        return StrokePoint(x: a.0 + (b.0 - a.0) * t, y: a.1 + (b.1 - a.1) * t, t: TimeInterval(t))
    })
}
