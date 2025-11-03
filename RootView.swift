import SwiftUI

struct RootView: View {
    @State private var env = AppEnvironment.live()
    @State private var selectedScript: KanaScript = .hiragana
    
    enum KanaScript: String, CaseIterable {
        case hiragana = "Hiragana"
        case katakana = "Katakana"
        case chineseNumbers = "Chinese Numbers"
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 24) {
                    // Script selection
                    Picker("Script", selection: $selectedScript) {
                        ForEach(KanaScript.allCases, id: \.self) { script in
                            Text(script.rawValue).tag(script)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            NavigationLink {
                                LessonViewLoader(script: selectedScript, env: env)
                            } label: {
                                Label {
                                    Text("Demo")
                                } icon: {
                                    Image("machine_writing_Icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 80)
                                }
                                .padding()
                                .background(Color(.systemGray3))
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                PracticeViewLoader(script: selectedScript, env: env)
                            } label: {
                                Label {
                                    Text("Practice")
                                } icon: {
                                    Image("child_writing_icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 80)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray3))
                            Spacer()
                        }
                        
                        // Sequential practice option for all scripts
                        NavigationLink {
                            switch selectedScript {
                            case .hiragana:
                                KanaSetSelector(env: env, script: .hiragana)
                            case .katakana:
                                KanaSetSelector(env: env, script: .katakana)
                            case .chineseNumbers:
                                ChineseNumberSetSelector(env: env)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "list.number")
                                    .font(.title2)
                                Text("Sequential Practice Sets")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundStyle(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Version and build number
                    if let versionBuild = versionAndBuildNumber() {
                        Text(versionBuild)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .navigationTitle("KanjiKana Trainer")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    /// Returns the version and build number string from the app's Info.plist
    private func versionAndBuildNumber() -> String? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return nil
        }
        return "Version \(version) (\(build))"
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
            // First, try to get characters with available stroke data
            let availableCodepoints: [UInt32]
            let scriptRange: ClosedRange<UInt32>
            let scriptType: Script
            
            switch script {
            case .hiragana:
                availableCodepoints = KanaStrokeDataLoader.shared.availableCodepoints
                scriptRange = 0x3040...0x309F
                scriptType = .kana
            case .katakana:
                availableCodepoints = KanaStrokeDataLoader.shared.availableCodepoints
                scriptRange = 0x30A0...0x30FF
                scriptType = .kana
            case .chineseNumbers:
                availableCodepoints = ChineseStrokeDataLoader.shared.availableCodepoints
                // Chinese number range (including common numbers)
                scriptRange = 0x4E00...0x9FFF  // Main CJK Unified Ideographs block
                scriptType = .hanzi
            }
            
            let availableInScript = availableCodepoints.filter { scriptRange.contains($0) }
            
            let randomID: CharacterID
            
            if !availableInScript.isEmpty {
                // Use stroke data if available
                let randomCodepoint = availableInScript.randomElement()!
                randomID = CharacterID(script: scriptType, codepoint: Int(randomCodepoint))
                print("✅ Using character with stroke data: U+\(String(format: "%04X", randomCodepoint))")
            } else {
                // Fall back to random character generation (will use synthetic strokes)
                print("⚠️ No stroke data available for \(script.rawValue), using synthetic strokes")
                randomID = randomCharacterID(for: script)
            }
            
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
        case .chineseNumbers:
            // Chinese numbers 0-30 (includes both single and compound characters)
            // Single characters: 0-10 use positive codepoints
            // Compound numbers: 11-30 use negative numbers
            let singleNumbers: [Int] = [
                0x96F6, // 0 (零)
                0x4E00, // 1 (一)
                0x4E8C, // 2 (二)
                0x4E09, // 3 (三)
                0x56DB, // 4 (四)
                0x4E94, // 5 (五)
                0x516D, // 6 (六)
                0x4E03, // 7 (七)
                0x516B, // 8 (八)
                0x4E5D, // 9 (九)
                0x5341  // 10 (十)
            ]
            let compoundNumbers: [Int] = Array(11...30) // 11-30 as identifiers
            
            // Randomly choose between single or compound
            let allNumbers = singleNumbers + compoundNumbers.map { -$0 } // Negative for compounds
            let codepoint = allNumbers.randomElement()!
            return CharacterID(script: .hanzi, codepoint: codepoint)
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
        case .chineseNumbers:
            // Chinese numbers 0-30 (includes both single and compound characters)
            // Single characters: 0-10 use positive codepoints
            // Compound numbers: 11-30 use negative numbers
            let singleNumbers: [Int] = [
                0x96F6, // 0 (零)
                0x4E00, // 1 (一)
                0x4E8C, // 2 (二)
                0x4E09, // 3 (三)
                0x56DB, // 4 (四)
                0x4E94, // 5 (五)
                0x516D, // 6 (六)
                0x4E03, // 7 (七)
                0x516B, // 8 (八)
                0x4E5D, // 9 (九)
                0x5341  // 10 (十)
            ]
            let compoundNumbers: [Int] = Array(11...30) // 11-30 as identifiers
            
            // Randomly choose between single or compound
            let allNumbers = singleNumbers + compoundNumbers.map { -$0 } // Negative for compounds
            let codepoint = allNumbers.randomElement()!
            return CharacterID(script: .hanzi, codepoint: codepoint)
        }
    }
}

#Preview {
    RootView()
}
