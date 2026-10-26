import Foundation

protocol AttemptEvaluator {
    func evaluate(user: [StrokePath], ideal: [StrokePath]) -> PracticeScore
}

/// Scores a handwritten attempt against the reference strokes.
///
/// Built for a young learner: it checks the things a teacher checks first —
/// the right number of strokes, written in the right order and the right
/// direction, roughly in the right place — and is forgiving about exact shape.
///
/// The user's strokes come from PencilKit in canvas points; reference strokes
/// come in different coordinate systems (kana and Chinese numbers are 0–1,
/// the 100 Chinese characters are on the 0–1024 hanzi-writer grid). Both sides
/// are normalised into the same unit box before anything is compared, so the
/// score does not depend on canvas size or on which data file a glyph came from.
struct DefaultAttemptEvaluator: AttemptEvaluator {

    /// Points each stroke is resampled to before comparing.
    var samplesPerStroke = 16
    /// Mean point distance (in unit-box units) at which a stroke's shape scores zero.
    var shapeTolerance = 0.30
    /// Strokes shorter than this (unit-box units) are treated as dots: any direction is fine.
    var dotLength = 0.06

    func evaluate(user: [StrokePath], ideal: [StrokePath]) -> PracticeScore {
        let userStrokes = StrokeGeometry.normalized(user).filter { !$0.isEmpty }
        let idealStrokes = StrokeGeometry.normalized(ideal).filter { !$0.isEmpty }
        guard !userStrokes.isEmpty, !idealStrokes.isEmpty else {
            return PracticeScore(orderAccuracy: 0, shapeSimilarity: 0)
        }

        let u = userStrokes.map { StrokeGeometry.resample($0, count: samplesPerStroke) }
        let r = idealStrokes.map { StrokeGeometry.resample($0, count: samplesPerStroke) }

        // Too many or too few strokes scales everything down.
        let countFactor = max(0, 1 - Double(abs(u.count - r.count)) / Double(r.count))
        let paired = min(u.count, r.count)

        var orderHits = 0.0
        var shapeTotal = 0.0
        for i in 0..<paired {
            // Order: is the reference stroke this one looks most like the one
            // that should come at this position?
            if StrokeGeometry.closestIndex(to: u[i], in: r) == i {
                // Direction: written the right way round (dots always pass).
                let isDot = StrokeGeometry.length(r[i]) < dotLength
                if isDot || StrokeGeometry.directionAgreement(u[i], r[i]) > 0 {
                    orderHits += 1
                } else {
                    orderHits += 0.5   // right stroke, written backwards
                }
            }
            let d = StrokeGeometry.meanDistance(u[i], r[i])
            shapeTotal += max(0, 1 - d / shapeTolerance)
        }

        let orderAccuracy = countFactor * orderHits / Double(r.count)
        let shapeSimilarity = countFactor * shapeTotal / Double(r.count)
        return PracticeScore(orderAccuracy: clamp(orderAccuracy), shapeSimilarity: clamp(shapeSimilarity))
    }

    private func clamp(_ v: Double) -> Double { min(1, max(0, v)) }
}

/// Plain geometry helpers on strokes, kept separate so they can be tested.
enum StrokeGeometry {
    typealias Point = (x: Double, y: Double)

    /// Maps all strokes into a unit box together (keeping aspect ratio and the
    /// strokes' positions relative to each other), centred at (0.5, 0.5).
    static func normalized(_ strokes: [StrokePath]) -> [[Point]] {
        let all = strokes.flatMap { $0.points }
        guard let first = all.first else { return strokes.map { _ in [] } }
        var minX = Double(first.x), maxX = minX, minY = Double(first.y), maxY = minY
        for p in all {
            minX = min(minX, Double(p.x)); maxX = max(maxX, Double(p.x))
            minY = min(minY, Double(p.y)); maxY = max(maxY, Double(p.y))
        }
        let side = max(maxX - minX, maxY - minY)
        let scale = side > 0 ? 1 / side : 1
        let cx = (minX + maxX) / 2, cy = (minY + maxY) / 2
        return strokes.map { stroke in
            stroke.points.map { p in
                (x: 0.5 + (Double(p.x) - cx) * scale, y: 0.5 + (Double(p.y) - cy) * scale)
            }
        }
    }

    static func length(_ s: [Point]) -> Double {
        guard s.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<s.count { total += hypot(s[i].x - s[i - 1].x, s[i].y - s[i - 1].y) }
        return total
    }

    /// Resamples a stroke to `count` points evenly spaced along its length.
    static func resample(_ s: [Point], count: Int) -> [Point] {
        guard let first = s.first, count > 1 else { return s }
        let total = length(s)
        guard total > 0 else { return Array(repeating: first, count: count) }
        let step = total / Double(count - 1)
        var out: [Point] = [first]
        var prev = first
        var carried = 0.0
        var i = 1
        while i < s.count && out.count < count {
            let next = s[i]
            let seg = hypot(next.x - prev.x, next.y - prev.y)
            if carried + seg >= step && seg > 0 {
                let t = (step - carried) / seg
                let p = (x: prev.x + t * (next.x - prev.x), y: prev.y + t * (next.y - prev.y))
                out.append(p)
                prev = p
                carried = 0
            } else {
                carried += seg
                prev = next
                i += 1
            }
        }
        while out.count < count { out.append(s[s.count - 1]) }
        return out
    }

    /// Mean distance between corresponding points of two equally resampled strokes.
    static func meanDistance(_ a: [Point], _ b: [Point]) -> Double {
        let n = min(a.count, b.count)
        guard n > 0 else { return .infinity }
        var total = 0.0
        for i in 0..<n { total += hypot(a[i].x - b[i].x, a[i].y - b[i].y) }
        return total / Double(n)
    }

    /// Distance ignoring direction: the smaller of forwards and reversed.
    static func shapeDistance(_ a: [Point], _ b: [Point]) -> Double {
        min(meanDistance(a, b), meanDistance(a, Array(b.reversed())))
    }

    /// Index of the reference stroke most like `stroke`, ignoring direction.
    static func closestIndex(to stroke: [Point], in references: [[Point]]) -> Int? {
        references.indices.min { shapeDistance(stroke, references[$0]) < shapeDistance(stroke, references[$1]) }
    }

    /// Cosine of the angle between the start→end vectors (1 = same way, -1 = backwards).
    static func directionAgreement(_ a: [Point], _ b: [Point]) -> Double {
        guard let a0 = a.first, let a1 = a.last, let b0 = b.first, let b1 = b.last else { return 0 }
        let ax = a1.x - a0.x, ay = a1.y - a0.y, bx = b1.x - b0.x, by = b1.y - b0.y
        let la = hypot(ax, ay), lb = hypot(bx, by)
        guard la > 0, lb > 0 else { return 1 }
        return (ax * bx + ay * by) / (la * lb)
    }
}
