import SwiftUI

struct RootView: View {
    @State private var env = AppEnvironment.live()
    @State private var selectedScript: KanaScript = .hiragana
    
    enum KanaScript: String, CaseIterable {
        case hiragana = "Hiragana"
        case katakana = "Katakana"
        case chineseNumbers = "Chinese"
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 32) {
                        // Script selection card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Your Script")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Picker("Script", selection: $selectedScript) {
                                ForEach(KanaScript.allCases, id: \.self) { script in
                                    Text(script.rawValue).tag(script)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Quick Actions - Large buttons in 2x2 grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Start")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                // Demo Card
                                NavigationLink {
                                    LessonViewLoader(script: selectedScript, env: env)
                                } label: {
                                    QuickActionCard(
                                        title: "Demo",
                                        subtitle: "Watch & Learn",
                                        icon: "play.circle.fill",
                                        customImage: "machine_writing_Icon",
                                        gradient: LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                }
                                .buttonStyle(CardButtonStyle())
                                
                                // Practice Card
                                NavigationLink {
                                    PracticeViewLoader(script: selectedScript, env: env)
                                } label: {
                                    QuickActionCard(
                                        title: "Practice",
                                        subtitle: "Draw & Master",
                                        icon: "pencil.and.scribble",
                                        customImage: "child_writing_icon",
                                        gradient: LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                }
                                .buttonStyle(CardButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                        
                        // Sequential Practice Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Structured Learning")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                // Sequential Demo Sets
                                NavigationLink {
                                    switch selectedScript {
                                    case .hiragana:
                                        DemoSetSelector(env: env, script: .hiragana)
                                    case .katakana:
                                        DemoSetSelector(env: env, script: .katakana)
                                    case .chineseNumbers:
                                        ChineseDemoSetSelector(env: env)
                                    }
                                } label: {
                                    FeatureCard(
                                        title: "Sequential Demo Sets",
                                        subtitle: "Step-by-step demonstrations",
                                        icon: "play.rectangle.on.rectangle.fill",
                                        accentColor: .orange
                                    )
                                }
                                .buttonStyle(CardButtonStyle())
                                
                                // Sequential Practice Sets
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
                                    FeatureCard(
                                        title: "Sequential Practice Sets",
                                        subtitle: "Organized practice sessions",
                                        icon: "list.number",
                                        accentColor: .purple
                                    )
                                }
                                .buttonStyle(CardButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Version and build number
                        if let versionBuild = versionAndBuildNumber() {
                            Text(versionBuild)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("KanjiKana Trainer")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .foregroundStyle(.blue)
                        }
                    }
                }
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

// MARK: - Custom Card Components

/// Large card for quick action buttons (Demo/Practice)
struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let customImage: String?
    let gradient: LinearGradient
    
    init(title: String, subtitle: String, icon: String, customImage: String? = nil, gradient: LinearGradient) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.customImage = customImage
        self.gradient = gradient
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon section
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                if let customImage = customImage {
                    Image(customImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
            }
            
            // Text section
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

/// Feature card for sequential practice/demo sets
struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(accentColor)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

/// Custom button style for cards
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    RootView()
}
