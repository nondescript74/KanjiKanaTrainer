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
    
    // MARK: - Chinese Common Characters (100 characters)
    
    /// Body Parts & People (8 characters)
    static func chineseBodyParts(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x4EBA, // 人 person
            0x53E3, // 口 mouth
            0x624B, // 手 hand
            0x76EE, // 目 eye
            0x8033, // 耳 ear
            0x5FC3, // 心 heart
            0x5973, // 女 woman
            0x5B50  // 子 child
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// Nature & Elements (17 characters)
    static func chineseNature(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x65E5, // 日 sun/day
            0x6708, // 月 moon/month
            0x6C34, // 水 water
            0x706B, // 火 fire
            0x6728, // 木 wood
            0x91D1, // 金 gold/metal
            0x571F, // 土 earth
            0x5929, // 天 sky
            0x5730, // 地 ground
            0x5C71, // 山 mountain
            0x7530, // 田 field
            0x77F3, // 石 stone
            0x98CE, // 风 wind
            0x4E91, // 云 cloud
            0x96E8, // 雨 rain
            0x96EA, // 雪 snow
            0x7535  // 电 electricity
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// Size & Direction (11 characters)
    static func chineseSizeDirection(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x5927, // 大 big
            0x5C0F, // 小 small
            0x4E2D, // 中 middle
            0x4E0A, // 上 up
            0x4E0B, // 下 down
            0x5DE6, // 左 left
            0x53F3, // 右 right
            0x957F, // 长 long
            0x591A, // 多 many
            0x5C11, // 少 few
            0x9AD8  // 高 tall/high
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// Common Objects & Animals (18 characters)
    static func chineseObjects(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x95E8, // 门 door
            0x9A6C, // 马 horse
            0x725B, // 牛 ox
            0x7F8A, // 羊 sheep
            0x9E1F, // 鸟 bird
            0x9C7C, // 鱼 fish
            0x7C73, // 米 rice
            0x7AF9, // 竹 bamboo
            0x4E1D, // 丝 silk
            0x866B, // 虫 insect
            0x8D1D, // 贝 shell
            0x89C1, // 见 see
            0x8F66, // 车 vehicle
            0x5200, // 刀 knife
            0x529B, // 力 strength
            0x53C8, // 又 again
            0x6587, // 文 culture
            0x65B9  // 方 square
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// Pronouns & Common Words (10 characters)
    static func chinesePronouns(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x4E0D, // 不 not
            0x4E5F, // 也 also
            0x4E86, // 了 completed
            0x5728, // 在 at/in
            0x6709, // 有 have
            0x6211, // 我 I
            0x4F60, // 你 you
            0x4ED6, // 他 he
            0x5979, // 她 she
            0x597D  // 好 good
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// Common Verbs (18 characters)
    static func chineseVerbs(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x6765, // 来 come
            0x53BB, // 去 go
            0x51FA, // 出 exit
            0x5165, // 入 enter
            0x5403, // 吃 eat
            0x559D, // 喝 drink
            0x770B, // 看 look/see
            0x542C, // 听 listen
            0x8BF4, // 说 speak
            0x8BFB, // 读 read
            0x5199, // 写 write
            0x8D70, // 走 walk
            0x98DE, // 飞 fly
            0x5750, // 坐 sit
            0x7AD9, // 站 stand
            0x7231, // 爱 love
            0x7B11, // 笑 laugh
            0x54ED  // 哭 cry
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// More Common Words (8 characters)
    static func chineseCommonWords(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            0x672C, // 本 root/book
            0x767D, // 白 white
            0x7EA2, // 红 red
            0x5F00, // 开 open
            0x751F, // 生 life/grow
            0x5B66, // 学 study
            0x5DE5, // 工 work
            0x7528  // 用 use
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialDemoViewModel(glyphIDs: ids, env: env)
    }
    
    /// All 100 Common Characters
    static func chineseCommonAll(env: AppEnvironment) -> SequentialDemoViewModel {
        let codepoints: [Int] = [
            // Body Parts & People (8)
            0x4EBA, 0x53E3, 0x624B, 0x76EE, 0x8033, 0x5FC3, 0x5973, 0x5B50,
            // Nature & Elements (17)
            0x65E5, 0x6708, 0x6C34, 0x706B, 0x6728, 0x91D1, 0x571F, 0x5929,
            0x5730, 0x5C71, 0x7530, 0x77F3, 0x98CE, 0x4E91, 0x96E8, 0x96EA, 0x7535,
            // Size & Direction (11)
            0x5927, 0x5C0F, 0x4E2D, 0x4E0A, 0x4E0B, 0x5DE6, 0x53F3, 0x957F,
            0x591A, 0x5C11, 0x9AD8,
            // Common Objects & Animals (18)
            0x95E8, 0x9A6C, 0x725B, 0x7F8A, 0x9E1F, 0x9C7C, 0x7C73, 0x7AF9,
            0x4E1D, 0x866B, 0x8D1D, 0x89C1, 0x8F66, 0x5200, 0x529B, 0x53C8, 0x6587, 0x65B9,
            // Pronouns & Common Words (10)
            0x4E0D, 0x4E5F, 0x4E86, 0x5728, 0x6709, 0x6211, 0x4F60, 0x4ED6, 0x5979, 0x597D,
            // Common Verbs (18)
            0x6765, 0x53BB, 0x51FA, 0x5165, 0x5403, 0x559D, 0x770B, 0x542C,
            0x8BF4, 0x8BFB, 0x5199, 0x8D70, 0x98DE, 0x5750, 0x7AD9, 0x7231, 0x7B11, 0x54ED,
            // More Common Words (8)
            0x672C, 0x767D, 0x7EA2, 0x5F00, 0x751F, 0x5B66, 0x5DE5, 0x7528
        ]
        let ids = codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
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
