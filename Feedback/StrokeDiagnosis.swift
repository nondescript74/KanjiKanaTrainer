import Foundation

/// The basic stroke families a teacher names when correcting a child.
nonisolated enum StrokeKind: String {
    case horizontal, vertical, leftFalling, rightFalling, dot

    /// Plain English name, used for kana.
    var plainName: String {
        switch self {
        case .horizontal:   return "horizontal stroke"
        case .vertical:     return "vertical stroke"
        case .leftFalling:  return "left-falling stroke"
        case .rightFalling: return "right-falling stroke"
        case .dot:          return "dot"
        }
    }

    /// English name with the Chinese term a classroom would use.
    var name: String {
        switch self {
        case .horizontal:   return "horizontal stroke (héng)"
        case .vertical:     return "vertical stroke (shù)"
        case .leftFalling:  return "left-falling stroke (piě)"
        case .rightFalling: return "right-falling stroke (nà)"
        case .dot:          return "dot (diǎn)"
        }
    }

    /// Plain direction, used for VoiceOver and hints.
    var direction: String {
        switch self {
        case .horizontal:   return "left to right"
        case .vertical:     return "top to bottom"
        case .leftFalling:  return "from upper right down to the lower left"
        case .rightFalling: return "from upper left down to the lower right"
        case .dot:          return "a short tap downward"
        }
    }

    /// Classifies a stroke (unit box, y down) by its start → end vector.
    static func classify(_ s: [StrokeGeometry.Point]) -> StrokeKind {
        guard let a = s.first, let b = s.last else { return .dot }
        if StrokeGeometry.length(s) < 0.12 { return .dot }
        let dx = b.x - a.x, dy = b.y - a.y
        if abs(dy) < 0.4 * abs(dx) { return .horizontal }
        if abs(dx) < 0.4 * abs(dy) { return .vertical }
        if dy > 0 { return dx < 0 ? .leftFalling : .rightFalling }
        return .horizontal
    }
}

/// What happened to one written stroke.
nonisolated enum StrokeVerdict: Equatable {
    case correct
    case wrongOrder(belongsAt: Int)   // 0-based reference index this stroke really is
    case backwards
    case offShape
    case extra

    var isMistake: Bool { self != .correct }
}

/// A full stroke-by-stroke diagnosis of one attempt, for the mistake overlay.
nonisolated struct StrokeDiagnosis {
    /// User strokes and reference strokes in the same unit box the evaluator uses.
    let user: [[StrokeGeometry.Point]]
    let reference: [[StrokeGeometry.Point]]
    let verdicts: [StrokeVerdict]          // one per user stroke
    let missing: [Int]                     // reference strokes never written
    let score: PracticeScore

    /// Index of the first user stroke that went wrong, if any.
    var firstMistake: Int? { verdicts.firstIndex { $0.isMistake } }
    var isPerfect: Bool { firstMistake == nil && missing.isEmpty && verdicts.count == reference.count }

    /// The reference stroke the learner should look at for the first problem.
    var focusReferenceIndex: Int? {
        if let i = firstMistake { return i < reference.count ? i : nil }
        return missing.first
    }

    /// Whether hints use Chinese stroke names (héng, shù, …). Off for kana.
    var usesChineseTerms = true

    func kind(ofReference i: Int) -> StrokeKind { StrokeKind.classify(reference[i]) }
    private func strokeName(_ i: Int) -> String {
        usesChineseTerms ? kind(ofReference: i).name : kind(ofReference: i).plainName
    }

    /// One short, kind sentence about the first problem — what a teacher would say.
    var hint: String {
        if isPerfect {
            return score.total >= 0.8 ? "Every stroke in the right order and direction. Beautiful."
                                      : "Right order and direction. Now try to match the shape a little more closely."
        }
        if let i = firstMistake {
            let n = i + 1
            switch verdicts[i] {
            case .wrongOrder(let j):
                let should = strokeName(i)
                let wrote = strokeName(j)
                return "Stroke \(n) should be the \(should). You wrote the \(wrote) there — it comes \(j > i ? "later" : "earlier")."
            case .backwards:
                return "Stroke \(n), the \(strokeName(i)), goes \(kind(ofReference: i).direction). You wrote it the other way round."
            case .offShape:
                return "Stroke \(n) is in the right order but drifted. Watch where the \(strokeName(i)) starts and ends."
            case .extra:
                return "This character has \(reference.count) strokes. You wrote \(user.count) — try fewer, longer strokes."
            case .correct:
                break
            }
        }
        if let m = missing.first {
            return "Stroke \(m + 1), the \(strokeName(m)), is missing."
        }
        return "Almost there — try once more."
    }

    /// Builds the diagnosis using the same normalisation and matching as `DefaultAttemptEvaluator`.
    init(user userPaths: [StrokePath], ideal: [StrokePath], usesChineseTerms: Bool = true,
         evaluator: DefaultAttemptEvaluator = DefaultAttemptEvaluator()) {
        self.usesChineseTerms = usesChineseTerms
        let u = StrokeGeometry.normalized(userPaths).filter { !$0.isEmpty }
        let r = StrokeGeometry.normalized(ideal).filter { !$0.isEmpty }
        user = u
        reference = r
        score = evaluator.evaluate(user: userPaths, ideal: ideal)

        let n = evaluator.samplesPerStroke
        let us = u.map { StrokeGeometry.resample($0, count: n) }
        let rs = r.map { StrokeGeometry.resample($0, count: n) }

        var v: [StrokeVerdict] = []
        var covered = Set<Int>()
        for i in us.indices {
            guard let j = StrokeGeometry.closestIndex(to: us[i], in: rs) else { v.append(.extra); continue }
            covered.insert(j)
            if i >= rs.count {
                v.append(.extra)
            } else if j != i {
                v.append(.wrongOrder(belongsAt: j))
            } else if StrokeGeometry.length(rs[i]) >= evaluator.dotLength,
                      StrokeGeometry.directionAgreement(us[i], rs[i]) <= 0 {
                v.append(.backwards)
            } else if StrokeGeometry.meanDistance(us[i], rs[i]) > evaluator.shapeTolerance * 0.7 {
                v.append(.offShape)
            } else {
                v.append(.correct)
            }
        }
        verdicts = v
        missing = rs.indices.filter { !covered.contains($0) && $0 >= us.count }
    }
}
