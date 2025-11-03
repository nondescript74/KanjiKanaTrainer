//
//  SequentialDemoViewModel.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

/// View model for sequential demo mode - demonstrates characters one after another
@MainActor
final class SequentialDemoViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The list of character IDs to demonstrate in sequence
    let glyphIDs: [CharacterID]
    
    /// Current index in the sequence
    @Published var currentIndex: Int = 0
    
    /// The currently loaded character
    @Published var currentGlyph: CharacterGlyph?
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error state
    @Published var error: Error?
    
    /// Demo playback state
    @Published var demoState: DemoState = .idle
    
    /// Currently drawn strokes during animation
    @Published var drawnStrokes: [[CGPoint]] = []
    
    /// Points being drawn in current stroke
    @Published var currentStroke: [CGPoint] = []
    
    /// Overall progress (0.0 to 1.0)
    @Published var progress: Double = 0.0
    
    /// Whether auto-play is enabled (automatically moves to next character)
    @Published var autoPlayEnabled: Bool = false
    
    // MARK: - Private Properties
    
    private let env: AppEnvironment
    private var animationTask: Task<Void, Never>?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Demo State Enum
    
    enum DemoState: Equatable {
        case idle
        case drawing
        case completed
    }
    
    // MARK: - Initialization
    
    init(glyphIDs: [CharacterID], env: AppEnvironment) {
        self.glyphIDs = glyphIDs
        self.env = env
    }
    
    deinit {
        animationTask?.cancel()
    }
    
    // MARK: - Computed Properties
    
    /// Whether there's a previous character available
    var hasPrevious: Bool {
        currentIndex > 0
    }
    
    /// Whether there's a next character available
    var hasNext: Bool {
        currentIndex < glyphIDs.count - 1
    }
    
    /// Progress string (e.g., "3 of 10")
    var progressString: String {
        "\(currentIndex + 1) of \(glyphIDs.count)"
    }
    
    /// Progress fraction for progress bar (0.0 to 1.0)
    var sequenceProgress: Double {
        guard glyphIDs.count > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(glyphIDs.count)
    }
    
    // MARK: - Character Navigation
    
    /// Load the character at the current index
    func loadCurrentGlyph() async {
        guard currentIndex >= 0 && currentIndex < glyphIDs.count else {
            return
        }
        
        isLoading = true
        error = nil
        stopDemo() // Stop any running demo
        
        do {
            let glyphID = glyphIDs[currentIndex]
            currentGlyph = try await env.glyphs.glyph(for: glyphID)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    /// Move to the next character in the sequence
    func nextGlyph() {
        guard hasNext else { return }
        currentIndex += 1
        Task {
            await loadCurrentGlyph()
            if autoPlayEnabled {
                startDemo()
            }
        }
    }
    
    /// Move to the previous character in the sequence
    func previousGlyph() {
        guard hasPrevious else { return }
        currentIndex -= 1
        Task {
            await loadCurrentGlyph()
            if autoPlayEnabled {
                startDemo()
            }
        }
    }
    
    /// Jump to a specific index
    func jumpTo(index: Int) {
        guard index >= 0 && index < glyphIDs.count else { return }
        currentIndex = index
        Task {
            await loadCurrentGlyph()
            if autoPlayEnabled {
                startDemo()
            }
        }
    }
    
    // MARK: - Demo Animation
    
    /// Start demonstrating the current character
    func startDemo() {
        guard let glyph = currentGlyph else {
            print("⚠️ Cannot start demo: Glyph not loaded")
            return
        }
        
        guard !glyph.strokes.isEmpty else {
            print("⚠️ No stroke data available for demo")
            print("   Character: '\(glyph.literal)' (U+\(String(format: "%04X", glyph.codepoint)))")
            return
        }
        
        // Cancel any existing animation
        animationTask?.cancel()
        
        // Reset state
        demoState = .drawing
        drawnStrokes = []
        currentStroke = []
        progress = 0.0
        
        // Start animated drawing
        animationTask = Task {
            await animateDrawing(strokes: glyph.strokes)
        }
    }
    
    /// Stop the demo animation
    func stopDemo() {
        animationTask?.cancel()
        demoState = .idle
        drawnStrokes = []
        currentStroke = []
        progress = 0.0
    }
    
    /// Replay the current demo
    func replayDemo() {
        startDemo()
    }
    
    private func animateDrawing(strokes: [StrokePath]) async {
        for (strokeIndex, strokePath) in strokes.enumerated() {
            guard !Task.isCancelled else { return }
            
            let points = strokePath.points.map { point in
                CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
            }
            
            guard !points.isEmpty else { continue }
            
            // Animate drawing this stroke point by point
            currentStroke = []
            
            for point in points {
                guard !Task.isCancelled else { return }
                currentStroke.append(point)
                try? await Task.sleep(nanoseconds: 15_000_000) // 15ms per point
            }
            
            // Stroke complete
            drawnStrokes.append(currentStroke)
            currentStroke = []
            
            // Update progress
            progress = Double(strokeIndex + 1) / Double(strokes.count)
            
            // Pause between strokes
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms between strokes
        }
        
        // All strokes complete
        demoState = .completed
        
        // Speak the character
        if let glyph = currentGlyph {
            speakCharacter(glyph)
        }
        
        // Auto-play: move to next after a delay
        if autoPlayEnabled && hasNext {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second pause
            if !Task.isCancelled {
                nextGlyph()
            }
        }
    }
    
    // MARK: - Speech Synthesis
    
    private func speakCharacter(_ glyph: CharacterGlyph) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: glyph.literal)
        
        switch glyph.script {
        case .kana:
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        case .kanji:
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        case .hanzi:
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        }
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        speechSynthesizer.speak(utterance)
    }
}

// MARK: - Factory Methods

extension SequentialDemoViewModel {
    
    // MARK: - Chinese Numbers
    
    static func chineseNumbers1to10(env: AppEnvironment) -> SequentialDemoViewModel {
        let numbers: [Int] = [
            0x4E00, 0x4E8C, 0x4E09, 0x56DB, 0x4E94,
            0x516D, 0x4E03, 0x516B, 0x4E5D, 0x5341
        ]
        let ids = numbers.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    // MARK: - Hiragana
    
    static func hiraganaVowels(env: AppEnvironment) -> SequentialDemoViewModel {
        let vowels: [Int] = [0x3042, 0x3044, 0x3046, 0x3048, 0x304A]
        let ids = vowels.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    static func hiraganaComplete(env: AppEnvironment) -> SequentialDemoViewModel {
        let all: [Int] = [
            0x3042, 0x3044, 0x3046, 0x3048, 0x304A,
            0x304B, 0x304D, 0x304F, 0x3051, 0x3053,
            0x3055, 0x3057, 0x3059, 0x305B, 0x305D,
            0x305F, 0x3061, 0x3064, 0x3066, 0x3068,
            0x306A, 0x306B, 0x306C, 0x306D, 0x306E,
            0x306F, 0x3072, 0x3075, 0x3078, 0x307B,
            0x307E, 0x307F, 0x3080, 0x3081, 0x3082,
            0x3084, 0x3086, 0x3088,
            0x3089, 0x308A, 0x308B, 0x308C, 0x308D,
            0x308F, 0x3092, 0x3093
        ]
        let ids = all.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    // MARK: - Katakana
    
    static func katakanaVowels(env: AppEnvironment) -> SequentialDemoViewModel {
        let vowels: [Int] = [0x30A2, 0x30A4, 0x30A6, 0x30A8, 0x30AA]
        let ids = vowels.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    static func katakanaComplete(env: AppEnvironment) -> SequentialDemoViewModel {
        let all: [Int] = [
            0x30A2, 0x30A4, 0x30A6, 0x30A8, 0x30AA,
            0x30AB, 0x30AD, 0x30AF, 0x30B1, 0x30B3,
            0x30B5, 0x30B7, 0x30B9, 0x30BB, 0x30BD,
            0x30BF, 0x30C1, 0x30C4, 0x30C6, 0x30C8,
            0x30CA, 0x30CB, 0x30CC, 0x30CD, 0x30CE,
            0x30CF, 0x30D2, 0x30D5, 0x30D8, 0x30DB,
            0x30DE, 0x30DF, 0x30E0, 0x30E1, 0x30E2,
            0x30E4, 0x30E6, 0x30E8,
            0x30E9, 0x30EA, 0x30EB, 0x30EC, 0x30ED,
            0x30EF, 0x30F2, 0x30F3
        ]
        let ids = all.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
}
