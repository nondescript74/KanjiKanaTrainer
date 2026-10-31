import SwiftUI

/// Lays the learner's strokes over the reference and points at the first thing to fix.
///
/// Both sides are drawn in the same normalised box the scorer uses, so what the
/// child sees is exactly what was judged.
struct MistakeOverlay: View {
    let diagnosis: StrokeDiagnosis
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { g in
                let inset = g.size.width * 0.12
                let rect = CGRect(origin: .zero, size: g.size).insetBy(dx: inset, dy: inset)
                let w = g.size.width * 0.06
                ZStack(alignment: .topLeading) {
                    PracticeGrid()
                    // Reference ghost.
                    ForEach(diagnosis.reference.indices, id: \.self) { i in
                        StrokeShape(points: diagnosis.reference[i])
                            .path(in: rect)
                            .stroke(Color.secondary.opacity(0.22), style: .init(lineWidth: w * 1.6, lineCap: .round, lineJoin: .round))
                    }
                    // Learner strokes, coloured by verdict.
                    ForEach(diagnosis.user.indices, id: \.self) { i in
                        let isFocus = i == diagnosis.firstMistake
                        StrokeShape(points: diagnosis.user[i])
                            .path(in: rect)
                            .stroke(color(for: diagnosis.verdicts[i]).opacity(isFocus ? 1 : 0.85),
                                    style: .init(lineWidth: isFocus ? w * 0.9 : w * 0.6, lineCap: .round, lineJoin: .round))
                    }
                    // The stroke that should have been written: redrawn in a loop with its start marker.
                    if let f = diagnosis.focusReferenceIndex {
                        StrokeShape(points: diagnosis.reference[f])
                            .path(in: rect)
                            .trim(from: 0, to: reduceMotion ? 1 : pulse)
                            .stroke(Color.blue, style: .init(lineWidth: w * 0.45, lineCap: .round, lineJoin: .round, dash: [w * 0.6, w * 0.4]))
                        StrokeStartMarker(number: f + 1,
                                          stroke: diagnosis.reference[f].map { (x: ($0.x * rect.width + inset) / g.size.width,
                                                                               y: ($0.y * rect.height + inset) / g.size.height) },
                                          size: g.size, color: .blue)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Your strokes laid over the model character.")
            .accessibilityValue(diagnosis.hint)

            HStack(spacing: 8) {
                ForEach(diagnosis.verdicts.indices, id: \.self) { i in
                    chip(number: i + 1, verdict: diagnosis.verdicts[i])
                }
                ForEach(diagnosis.missing, id: \.self) { m in
                    Label("\(m + 1) missing", systemImage: "questionmark.circle")
                        .font(.caption.bold()).padding(6)
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }
            }
            .accessibilityElement(children: .combine)

            Text(diagnosis.hint)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                legend(.green, "right", "checkmark")
                legend(.orange, "needs work", "exclamationmark.triangle")
                legend(.blue, "the stroke to write", "pencil.tip")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
        }
        .onAppear {
            guard !reduceMotion else { return }
            pulse = 0
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) { pulse = 1 }
        }
    }

    private func color(for v: StrokeVerdict) -> Color {
        switch v {
        case .correct: return .green
        case .offShape: return .orange
        default: return .red
        }
    }

    private func chip(number: Int, verdict: StrokeVerdict) -> some View {
        let (text, icon): (String, String) = {
            switch verdict {
            case .correct: return ("\(number)", "checkmark")
            case .wrongOrder: return ("\(number) order", "arrow.left.arrow.right")
            case .backwards: return ("\(number) backwards", "arrow.uturn.backward")
            case .offShape: return ("\(number) shape", "scribble")
            case .extra: return ("\(number) extra", "plus")
            }
        }()
        return Label(text, systemImage: icon)
            .font(.caption.bold())
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(Capsule().fill(color(for: verdict).opacity(0.18)))
            .foregroundStyle(color(for: verdict) == .green ? Color.green : Color.primary)
    }

    private func legend(_ c: Color, _ t: String, _ icon: String) -> some View {
        Label(t, systemImage: icon).foregroundStyle(c)
    }
}
