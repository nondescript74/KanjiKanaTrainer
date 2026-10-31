import SwiftUI

/// The guided 3-minute experience: story → watch → write → fix a mistake → challenge → wrap-up.
struct ContentView: View {
    enum Step: Int, CaseIterable {
        case intro, watch, write, fix, challenge, finish
        var title: String {
            switch self {
            case .intro: return "The problem"
            case .watch: return "Watch"
            case .write: return "Write"
            case .fix: return "Fix a mistake"
            case .challenge: return "On your own"
            case .finish: return "What you learned"
            }
        }
    }

    @State private var step: Step = ContentView.launchStep

    /// Debug-only: KKT_STEP=<n> opens a given step (used for screenshots).
    private static var launchStep: Step {
        #if DEBUG
        if let v = ProcessInfo.processInfo.environment["KKT_STEP"], let n = Int(v), let s = Step(rawValue: n) { return s }
        #endif
        return .intro
    }
    @State private var best: [String: Double] = [:]
    @State private var caught: [String] = []

    private let ren = GlyphLibrary.glyph("人")
    private let da = GlyphLibrary.glyph("大")
    private let mu = GlyphLibrary.glyph("木")

    var body: some View {
        VStack(spacing: 0) {
            progressBar
            ScrollView {
                Group {
                    switch step {
                    case .intro: IntroView()
                    case .watch: if let g = ren { watch(g) }
                    case .write:
                        if let g = ren {
                            PracticeStep(glyph: g, prompt: "Two strokes. Trace over the guide — finger or Apple Pencil.",
                                         mistake: .swap(0, 1), onScored: record(g))
                        }
                    case .fix:
                        if let g = da {
                            PracticeStep(glyph: g, prompt: "Most children get the shape right and the order wrong. Try it — or tap the wand.",
                                         mistake: .reverse(0), onScored: record(g))
                        }
                    case .challenge:
                        if let g = mu {
                            PracticeStep(glyph: g, prompt: "No guide this time. Four strokes: across, down, then left and right.",
                                         showGuideByDefault: false, mistake: .swap(2, 3), onScored: record(g))
                        }
                    case .finish: FinishView(best: best, caught: caught)
                    }
                }
                .padding(24)
                .frame(maxWidth: 960)
                .frame(maxWidth: .infinity)
                .id(step)
            }
            navBar
        }
    }

    private func watch(_ g: Glyph) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("人 — rén — person").font(.largeTitle.bold())
            Text("A teacher checks more than the final shape: how many strokes, which comes first, and which way each one goes. Watch the numbered dots and arrows.")
                .font(.title3)
            StrokeOrderDemo(glyph: g).frame(maxWidth: 380).frame(maxWidth: .infinity)
        }
    }

    private func record(_ g: Glyph) -> (StrokeDiagnosis) -> Void {
        { d in
            best[g.literal] = max(best[g.literal] ?? 0, d.score.total)
            let entry = "\(g.literal): \(d.hint)"
            if !d.isPerfect, !caught.contains(entry) { caught.append(entry) }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(Step.allCases, id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 24).padding(.top, 12)
        .accessibilityElement()
        .accessibilityLabel("Step \(step.rawValue + 1) of \(Step.allCases.count): \(step.title)")
    }

    private var navBar: some View {
        HStack {
            if step != .intro {
                Button { go(-1) } label: { Label("Back", systemImage: "chevron.left") }
                    .buttonStyle(.bordered)
            }
            Spacer()
            Text(step.title).font(.headline).foregroundStyle(.secondary)
            Spacer()
            if step != .finish {
                Button { go(1) } label: { Label(step == .intro ? "Start" : "Next", systemImage: "chevron.right") }
                    .buttonStyle(.borderedProminent)
            } else {
                Button { step = .intro; best = [:]; caught = [] } label: { Label("Start over", systemImage: "arrow.counterclockwise") }
                    .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .background(.bar)
    }

    private func go(_ delta: Int) {
        if let s = Step(rawValue: step.rawValue + delta) {
            withAnimation(.easeInOut(duration: 0.25)) { step = s }
        }
    }
}

struct IntroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Stroke by stroke").font(.largeTitle.bold())
            Text("A seven-year-old in a Mandarin immersion class brings home a page of characters to practise. Her parents don't read Chinese. The page looks right — but is it?")
                .font(.title3)
            Text("In class, the teacher checks how a character is written, not just how it looks: the number of strokes, their order, and their direction. At home, nobody can.")
                .font(.title3)
            HStack(spacing: 16) {
                fact("number.circle", "Stroke count")
                fact("list.number", "Order")
                fact("arrow.up.right", "Direction")
                fact("scribble.variable", "Shape")
            }
            Text("This app watches each stroke as it is written and points at the first one to fix — on the device, with no account and no network.")
                .font(.title3).foregroundStyle(.secondary)
        }
    }

    private func fact(_ icon: String, _ t: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title)
            Text(t).font(.caption.bold())
        }
        .frame(maxWidth: .infinity).padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor.opacity(0.12)))
        .accessibilityElement(children: .combine)
    }
}

struct FinishView: View {
    let best: [String: Double]
    let caught: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("You wrote like a teacher checks").font(.largeTitle.bold())
            HStack(spacing: 16) {
                ForEach(["人", "大", "木"], id: \.self) { c in
                    VStack {
                        Text(c).font(.system(size: 48, weight: .bold))
                        Text(best[c].map { "\(Int(($0 * 100).rounded()))%" } ?? "—").font(.headline.monospacedDigit())
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    .accessibilityElement(children: .combine)
                }
            }
            if !caught.isEmpty {
                Text("Mistakes the app caught").font(.title2.bold())
                ForEach(caught, id: \.self) { Label($0, systemImage: "lightbulb").font(.body) }
            }
            Text("The full app covers numbers, family words, the first 100 characters and all 46 hiragana and katakana — and it stays entirely on the device.")
                .font(.title3).foregroundStyle(.secondary)
        }
    }
}
