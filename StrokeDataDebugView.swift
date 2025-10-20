import SwiftUI

#if DEBUG
/// Debug view for testing and validating stroke data loading
struct StrokeDataDebugView: View {
    @State private var validationResult: String = "Tap 'Run Validation' to check stroke data"
    @State private var isLoading = false
    @State private var selectedCharacter: String = "あ"
    @State private var strokePreview: [StrokePath]?
    
    let testCharacters = ["あ", "い", "う", "え", "お", "ア", "イ", "ウ", "エ", "オ"]
    
    var body: some View {
        NavigationView {
            List {
                Section("Quick Test") {
                    Picker("Test Character", selection: $selectedCharacter) {
                        ForEach(testCharacters, id: \.self) { char in
                            Text(char).tag(char)
                        }
                    }
                    .onChange(of: selectedCharacter) { _, newValue in
                        loadCharacter(newValue)
                    }
                    
                    if let strokes = strokePreview {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✅ Loaded successfully")
                                .foregroundStyle(.green)
                            Text("\(strokes.count) stroke(s)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // Preview
                            Canvas { context, size in
                                for stroke in strokes {
                                    guard !stroke.points.isEmpty else { continue }
                                    var path = Path()
                                    let points = stroke.points.map { point in
                                        CGPoint(
                                            x: CGFloat(point.x) * size.width,
                                            y: CGFloat(point.y) * size.height
                                        )
                                    }
                                    path.addLines(points)
                                    context.stroke(
                                        path,
                                        with: .color(.blue),
                                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                                    )
                                }
                            }
                            .frame(height: 120)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }
                    } else {
                        Text("⚠️ No stroke data found")
                            .foregroundStyle(.orange)
                    }
                }
                
                Section("Validation") {
                    Button(action: runValidation) {
                        HStack {
                            Text("Run Validation")
                            Spacer()
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoading)
                    
                    Text(validationResult)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Statistics") {
                    Button("Show Statistics") {
                        showStatistics()
                    }
                }
                
                Section("File Status") {
                    let fileExists = checkIfFileExists()
                    
                    HStack {
                        Image(systemName: fileExists ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(fileExists ? Color.green : Color.red)
                        Text(fileExists ? "kanastrokes.json found" : "kanastrokes.json NOT FOUND")
                            .foregroundStyle(fileExists ? Color.primary : Color.red)
                    }
                    
                    if !fileExists {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Stroke data file is missing!")
                                .font(.headline)
                                .foregroundStyle(.red)
                            
                            Text("The file should be at:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("strokedata/kanastrokes.json")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                            
                            Divider()
                            
                            Text("To fix:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Add the JSON file to your project")
                                Text("2. Ensure it's in a folder named 'strokedata'")
                                Text("3. Check it's added to your app target")
                                Text("4. Verify it's in 'Copy Bundle Resources'")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Available Characters") {
                    let loader = KanaStrokeDataLoader.shared
                    let count = loader.availableCharacters.count
                    
                    HStack {
                        Text("\(count) characters available")
                            .foregroundStyle(count > 0 ? Color.primary : Color.red)
                        
                        if count == 0 {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    
                    if count > 0 {
                        ScrollView(.horizontal) {
                            HStack(spacing: 4) {
                                ForEach(loader.availableCharacters.prefix(30), id: \.self) { char in
                                    Text(char)
                                        .font(.title3)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    } else {
                        Text("No stroke data loaded. Check the file status above.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Section("Test Integration") {
                    NavigationLink("Test Lesson View") {
                        TestLessonIntegration()
                    }
                }
            }
            .navigationTitle("Stroke Data Debug")
            .onAppear {
                loadCharacter(selectedCharacter)
            }
        }
    }
    
    private func loadCharacter(_ character: String) {
        strokePreview = KanaStrokeDataLoader.shared.loadStrokes(for: character)
    }
    
    private func checkIfFileExists() -> Bool {
        return Bundle.main.url(forResource: "kanastrokes", withExtension: "json", subdirectory: "strokedata") != nil
    }
    
    private func runValidation() {
        isLoading = true
        validationResult = "Validating..."
        
        Task {
            let summary = StrokeDataConverter.validateCombinedJSON()
            
            await MainActor.run {
                if summary.isValid {
                    validationResult = "✅ All \(summary.validCharacters) characters validated successfully!"
                } else {
                    var result = "⚠️ Found issues:\n"
                    result += "Valid: \(summary.validCharacters)/\(summary.totalCharacters)\n"
                    if !summary.failedCharacters.isEmpty {
                        result += "Failed to load: \(summary.failedCharacters.count)\n"
                    }
                    if !summary.emptyStrokes.isEmpty {
                        result += "Empty strokes: \(summary.emptyStrokes.count)\n"
                    }
                    if !summary.invalidCoordinates.isEmpty {
                        result += "Invalid coords: \(summary.invalidCoordinates.count)\n"
                    }
                    validationResult = result
                }
                isLoading = false
            }
        }
    }
    
    private func showStatistics() {
        StrokeDataConverter.printStatistics()
        validationResult = "Statistics printed to console"
    }
}

/// Test view to verify LessonView integration
private struct TestLessonIntegration: View {
    @StateObject private var viewModel: LessonViewModel
    @State private var env: AppEnvironment
    
    init() {
        let environment = AppEnvironment(
            glyphs: GlyphBundleRepository(),
            progress: SwiftDataProgressStore(),
            evaluator: DefaultAttemptEvaluator()
        )
        _env = State(initialValue: environment)
        
        // Test with hiragana あ (U+3042)
        let characterID = CharacterID(script: .kana, codepoint: Int(0x3042))
        _viewModel = StateObject(wrappedValue: LessonViewModel(id: characterID, env: environment))
    }
    
    var body: some View {
        LessonView(viewModel: viewModel)
    }
}

#Preview {
    StrokeDataDebugView()
}
#endif
