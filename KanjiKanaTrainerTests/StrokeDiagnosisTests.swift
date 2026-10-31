import Foundation
import Testing
@testable import KanjiKanaTrainer

/// The mistake overlay must point at the same stroke a teacher would.
struct StrokeDiagnosisTests {

    /// 十: across, then down (0–1 grid, y down).
    private let ten: [StrokePath] = [
        Self.line((0.1, 0.5), (0.9, 0.5)),
        Self.line((0.5, 0.1), (0.5, 0.9)),
    ]

    private static func line(_ a: (Float, Float), _ b: (Float, Float), steps: Int = 12) -> StrokePath {
        StrokePath(points: (0...steps).map { i in
            let t = Float(i) / Float(steps)
            return StrokePoint(x: a.0 + (b.0 - a.0) * t, y: a.1 + (b.1 - a.1) * t, t: TimeInterval(t))
        })
    }

    private func onCanvas(_ s: [StrokePath]) -> [StrokePath] {
        s.map { StrokePath(points: $0.points.map { StrokePoint(x: $0.x * 500 + 20, y: $0.y * 500 + 20, t: $0.t) }) }
    }

    @Test func aCorrectAttemptHasNoMistakes() {
        let d = StrokeDiagnosis(user: onCanvas(ten), ideal: ten)
        #expect(d.isPerfect)
        #expect(d.verdicts == [.correct, .correct])
    }

    @Test func swappedStrokesAreFlaggedAsWrongOrder() {
        let d = StrokeDiagnosis(user: onCanvas([ten[1], ten[0]]), ideal: ten)
        #expect(d.firstMistake == 0)
        #expect(d.verdicts[0] == .wrongOrder(belongsAt: 1))
        #expect(d.hint.contains("horizontal stroke (héng)"))
    }

    @Test func aBackwardsStrokeIsFlagged() {
        let reversed = StrokePath(points: ten[0].points.reversed())
        let d = StrokeDiagnosis(user: onCanvas([reversed, ten[1]]), ideal: ten)
        #expect(d.verdicts == [.backwards, .correct])
        #expect(d.hint.contains("left to right"))
    }

    @Test func aMissingStrokeIsReported() {
        let d = StrokeDiagnosis(user: onCanvas([ten[0]]), ideal: ten)
        #expect(d.missing == [1])
        #expect(d.focusReferenceIndex == 1)
    }

    @Test func kanaHintsUsePlainStrokeNames() {
        let d = StrokeDiagnosis(user: onCanvas([ten[1], ten[0]]), ideal: ten, usesChineseTerms: false)
        #expect(!d.hint.contains("héng"))
        #expect(d.hint.contains("horizontal stroke"))
    }

    @Test func strokeKindsAreClassified() {
        #expect(StrokeKind.classify([(x: 0.1, y: 0.5), (x: 0.9, y: 0.5)]) == .horizontal)
        #expect(StrokeKind.classify([(x: 0.5, y: 0.1), (x: 0.5, y: 0.9)]) == .vertical)
        #expect(StrokeKind.classify([(x: 0.8, y: 0.2), (x: 0.2, y: 0.8)]) == .leftFalling)
        #expect(StrokeKind.classify([(x: 0.2, y: 0.2), (x: 0.8, y: 0.8)]) == .rightFalling)
        #expect(StrokeKind.classify([(x: 0.5, y: 0.5), (x: 0.52, y: 0.55)]) == .dot)
    }
}
