import SwiftUI

struct RootView: View {
    @State private var env = AppEnvironment.live()
    @State private var selectedScript: KanaScript = .hiragana
    
    enum KanaScript: String, CaseIterable {
        case hiragana = "Hiragana"
        case katakana = "Katakana"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Script selection
                Picker("Script", selection: $selectedScript) {
                    ForEach(KanaScript.allCases, id: \.self) { script in
                        Text(script.rawValue).tag(script)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                NavigationLink("Lesson Demo") {
                    LessonViewLoader(script: selectedScript, env: env)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                NavigationLink("Practice Random Character") {
                    PracticeViewLoader(script: selectedScript, env: env)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("KanjiKana Trainer")
        }
    }
}

/// Helper view to load a random glyph for lesson
struct LessonViewLoader: View {
    let script: RootView.KanaScript
    let env: AppEnvironment
    @State private var glyph: CharacterGlyph?
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let glyph {
                LessonView(viewModel: LessonViewModel(id: glyph.id, env: env))
            } else if let error {
                ContentUnavailableView(
                    "Unable to Load Character",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else {
                ProgressView("Loading character...")
            }
        }
        .task {
            await loadRandomGlyph()
        }
        .onChange(of: script) { oldValue, newValue in
            Task {
                await loadRandomGlyph()
            }
        }
    }
    
    private func loadRandomGlyph() async {
        do {
            // Get all available characters with stroke data
            let availableCodepoints = KanaStrokeDataLoader.shared.availableCodepoints
            
            // Filter to only those in the selected script's range
            let scriptRange: ClosedRange<UInt32>
            switch script {
            case .hiragana:
                scriptRange = 0x3040...0x309F
            case .katakana:
                scriptRange = 0x30A0...0x30FF
            }
            
            let availableInScript = availableCodepoints.filter { scriptRange.contains($0) }
            
            guard !availableInScript.isEmpty else {
                print("❌ No stroke data available for \(script.rawValue)")
                print("   Available codepoints: \(availableCodepoints.map { String(format: "U+%04X", $0) }.joined(separator: ", "))")
                throw NSError(
                    domain: "LessonViewLoader",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "No characters found with stroke data for \(script.rawValue). Please add stroke data for \(script.rawValue) characters to kanastrokes.json in the strokedata folder."]
                )
            }
            
            // Pick a random character from available ones
            let randomCodepoint = availableInScript.randomElement()!
            let randomID = CharacterID(script: .kana, codepoint: Int(randomCodepoint))
            glyph = try await env.glyphs.glyph(for: randomID)
            
        } catch {
            self.error = error
        }
    }
    
    private func randomCharacterID(for script: RootView.KanaScript) -> CharacterID {
        switch script {
        case .hiragana:
            // Common hiragana range (avoiding small kana)
            let codepoint = Int.random(in: 0x3042...0x3093)
            return CharacterID(script: .kana, codepoint: codepoint)
        case .katakana:
            // Common katakana range (avoiding small kana)
            let codepoint = Int.random(in: 0x30A2...0x30F3)
            return CharacterID(script: .kana, codepoint: codepoint)
        }
    }
}

/// Helper view to load a random glyph asynchronously
struct PracticeViewLoader: View {
    let script: RootView.KanaScript
    let env: AppEnvironment
    @State private var glyph: CharacterGlyph?
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let glyph {
                PracticeView(viewModel: PracticeViewModel(glyph: glyph, env: env))
            } else if let error {
                ContentUnavailableView(
                    "Unable to Load Character",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else {
                ProgressView("Loading character...")
            }
        }
        .task {
            await loadRandomGlyph()
        }
        .onChange(of: script) { oldValue, newValue in
            Task {
                await loadRandomGlyph()
            }
        }
    }
    
    private func loadRandomGlyph() async {
        do {
            let randomID = randomCharacterID(for: script)
            glyph = try await env.glyphs.glyph(for: randomID)
        } catch {
            self.error = error
        }
    }
    
    private func randomCharacterID(for script: RootView.KanaScript) -> CharacterID {
        switch script {
        case .hiragana:
            // Common hiragana range (avoiding small kana)
            let codepoint = Int.random(in: 0x3042...0x3093)
            return CharacterID(script: .kana, codepoint: codepoint)
        case .katakana:
            // Common katakana range (avoiding small kana)
            let codepoint = Int.random(in: 0x30A2...0x30F3)
            return CharacterID(script: .kana, codepoint: codepoint)
        }
    }
}
