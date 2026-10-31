import SwiftUI

/// Draws a character one stroke at a time, the way a teacher writes it on the board.
struct StrokeOrderDemo: View {
    let glyph: Glyph
    var showMarkers = true
    var autoplay = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: Double = 0
    @State private var playID = 0

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { g in
                let size = g.size
                ZStack {
                    PracticeGrid()
                    ForEach(Array(glyph.strokes.enumerated()), id: \.offset) { i, s in
                        StrokeShape(points: s.unitPoints)
                            .stroke(Color.secondary.opacity(0.18), style: .init(lineWidth: size.width * 0.07, lineCap: .round, lineJoin: .round))
                        StrokeShape(points: s.unitPoints)
                            .trim(from: 0, to: max(0, min(1, progress - Double(i))))
                            .stroke(Color.primary, style: .init(lineWidth: size.width * 0.07, lineCap: .round, lineJoin: .round))
                    }
                    if showMarkers {
                        ForEach(Array(glyph.strokes.enumerated()), id: \.offset) { i, s in
                            if progress > Double(i) {
                                StrokeStartMarker(number: i + 1, stroke: s.unitPoints, size: size)
                            }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityDescription)

            Button {
                play()
            } label: {
                Label("Play again", systemImage: "play.circle.fill")
            }
            .buttonStyle(.bordered)
        }
        .task(id: playID) { await animate() }
        .onAppear { if autoplay { play() } }
    }

    private var accessibilityDescription: String {
        let parts = glyph.strokes.enumerated().map { i, s -> String in
            let k = StrokeKind.classify(s.unitPoints)
            return "Stroke \(i + 1): \(k.name), \(k.direction)."
        }
        return "\(glyph.literal), \(glyph.pinyin), meaning \(glyph.meaning). \(glyph.strokes.count) strokes. " + parts.joined(separator: " ")
    }

    private func play() { playID += 1 }

    private func animate() async {
        guard playID > 0 else { return }
        progress = 0
        if reduceMotion {
            progress = Double(glyph.strokes.count)
            Speech.shared.say(glyph.literal)
            return
        }
        try? await Task.sleep(nanoseconds: 300_000_000)
        for i in glyph.strokes.indices {
            withAnimation(.easeInOut(duration: 0.7)) { progress = Double(i + 1) }
            Haptics.tap()
            try? await Task.sleep(nanoseconds: 900_000_000)
            if Task.isCancelled { return }
        }
        Speech.shared.say(glyph.literal)
    }
}
