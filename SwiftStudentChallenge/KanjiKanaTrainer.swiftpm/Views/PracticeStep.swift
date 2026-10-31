import SwiftUI
import PencilKit

/// A scripted slip a learner commonly makes, so a judge can see feedback without writing.
enum CommonMistake {
    case swap(Int, Int)
    case reverse(Int)

    var label: String {
        switch self {
        case .swap: return "Show a common mistake: wrong order"
        case .reverse: return "Show a common mistake: backwards stroke"
        }
    }

    func apply(to strokes: [StrokePath]) -> [StrokePath] {
        var s = strokes
        switch self {
        case .swap(let a, let b): s.swapAt(a, b)
        case .reverse(let i): s[i] = StrokePath(points: s[i].points.reversed())
        }
        return s
    }
}

/// Write a character, then see exactly which stroke went wrong.
struct PracticeStep: View {
    let glyph: Glyph
    let prompt: String
    var showGuideByDefault = true
    var mistake: CommonMistake?
    var onScored: (StrokeDiagnosis) -> Void = { _ in }

    @State private var drawing = PKDrawing()
    @State private var diagnosis: StrokeDiagnosis?
    @State private var showGuide = true
    @State private var showDemo = false
    @State private var canvasSize: CGSize = .zero
    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            let layout = hSize == .regular ? AnyLayout(HStackLayout(alignment: .top, spacing: 24))
                                           : AnyLayout(VStackLayout(spacing: 16))
            layout {
                VStack(spacing: 12) {
                    canvas
                    controls
                }
                // Fixed width on iPad so the canvas never resizes under the learner's ink.
                .frame(width: hSize == .regular ? 380 : nil)

                if let d = diagnosis {
                    VStack(alignment: .leading, spacing: 8) {
                        scoreLine(d)
                        MistakeOverlay(diagnosis: d)
                            .id(d.verdicts.description + "\(d.score.total)")
                    }
                    .frame(width: hSize == .regular ? 360 : nil)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else if showDemo {
                    StrokeOrderDemo(glyph: glyph).frame(width: hSize == .regular ? 320 : nil)
                }
            }
        }
        .onAppear {
            showGuide = showGuideByDefault
            #if DEBUG
            if ProcessInfo.processInfo.environment["KKT_MISTAKE"] != nil, let m = mistake {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    drawing = PKDrawing.from(m.apply(to: glyph.strokes), in: canvasSize)
                    check()
                }
            }
            #endif
        }
        .animation(.spring(duration: 0.35), value: diagnosis?.score.total)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(glyph.literal).font(.system(size: 44, weight: .bold))
            VStack(alignment: .leading) {
                Text("\(glyph.pinyin) · \(glyph.meaning) · \(glyph.strokes.count) strokes").font(.headline)
                Text(prompt).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button { Speech.shared.say(glyph.literal) } label: {
                Image(systemName: "speaker.wave.2.fill").font(.title2)
            }
            .accessibilityLabel("Hear \(glyph.pinyin)")
        }
    }

    private var canvas: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground))
                PracticeGrid()
                if showGuide {
                    ForEach(Array(glyph.strokes.enumerated()), id: \.offset) { _, s in
                        StrokeShape(points: s.unitPoints)
                            .stroke(Color.secondary.opacity(0.15), style: .init(lineWidth: g.size.width * 0.07, lineCap: .round, lineJoin: .round))
                    }
                }
                WritingCanvas(drawing: $drawing)
            }
            .onChange(of: g.size, initial: true) { _, new in canvasSize = new }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Button(role: .destructive) { clear() } label: { Label("Clear", systemImage: "eraser") }
                    .buttonStyle(.bordered)
                Toggle(isOn: $showGuide) { Label("Guide", systemImage: "square.dashed") }
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                Button { showDemo.toggle(); diagnosis = nil } label: { Label("Watch", systemImage: "play.rectangle") }
                    .buttonStyle(.bordered)
            }
            .lineLimit(1)
            .fixedSize()
            Button { check() } label: {
                Label("Check my writing", systemImage: "checkmark.seal.fill").bold().frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(drawing.strokes.isEmpty)
            if let m = mistake {
                Button {
                    drawing = PKDrawing.from(m.apply(to: glyph.strokes), in: canvasSize)
                    check()
                } label: {
                    Label(m.label, systemImage: "wand.and.stars").font(.footnote)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func scoreLine(_ d: StrokeDiagnosis) -> some View {
        let pct = Int((d.score.total * 100).rounded())
        return HStack {
            Image(systemName: d.isPerfect ? "star.circle.fill" : "lightbulb.fill")
                .foregroundStyle(d.isPerfect ? .yellow : .orange)
            Text("\(pct)%").font(.title2.bold().monospacedDigit())
            Text("order \(Int(d.score.orderAccuracy * 100))% · shape \(Int(d.score.shapeSimilarity * 100))%")
                .font(.caption).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func clear() {
        drawing = PKDrawing()
        diagnosis = nil
    }

    private func check() {
        // Give PencilKit a beat to publish a programmatic drawing before reading it.
        DispatchQueue.main.async {
            let d = StrokeDiagnosis(user: drawing.strokePaths, ideal: glyph.strokes)
            showDemo = false
            diagnosis = d
            d.isPerfect ? Haptics.success() : Haptics.warning()
            UIAccessibility.post(notification: .announcement, argument: d.hint)
            onScored(d)
        }
    }
}
