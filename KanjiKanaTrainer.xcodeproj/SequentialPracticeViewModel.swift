//
//  SequentialPracticeViewModel.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/2/25.
//

import Foundation
import PencilKit
import Combine

@MainActor
final class SequentialPracticeViewModel: ObservableObject {
    private let env: AppEnvironment
    private let glyphIDs: [CharacterID]
    
    @Published var currentIndex: Int = 0
    @Published var currentGlyph: CharacterGlyph?
    @Published var score: PracticeScore?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    var currentNumber: Int {
        currentIndex + 1
    }
    
    var totalCount: Int {
        glyphIDs.count
    }
    
    var hasNext: Bool {
        currentIndex < glyphIDs.count - 1
    }
    
    var hasPrevious: Bool {
        currentIndex > 0
    }
    
    init(glyphIDs: [CharacterID], env: AppEnvironment) {
        self.glyphIDs = glyphIDs
        self.env = env
    }
    
    func loadCurrentGlyph() async {
        guard currentIndex < glyphIDs.count else { return }
        isLoading = true
        error = nil
        
        do {
            let id = glyphIDs[currentIndex]
            currentGlyph = try await env.glyphs.glyph(for: id)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func nextGlyph() async {
        guard hasNext else { return }
        currentIndex += 1
        score = nil
        await loadCurrentGlyph()
    }
    
    func previousGlyph() async {
        guard hasPrevious else { return }
        currentIndex -= 1
        score = nil
        await loadCurrentGlyph()
    }
    
    func clearScore() {
        score = nil
    }
    
    func evaluate(_ drawing: PKDrawing) {
        guard let glyph = currentGlyph else { return }
        
        let strokes = drawing.strokes.map { stroke -> StrokePath in
            let points = stroke.path.map {
                StrokePoint(x: Float($0.location.x),
                            y: Float($0.location.y),
                            t: TimeInterval(Float($0.timeOffset)))
            }
            return StrokePath(points: points)
        }

        let attemptScore = env.evaluator.evaluate(user: strokes, ideal: glyph.strokes)
        score = attemptScore
    }
    
    // MARK: - Factory Methods for Different Number Sets
    
    /// Creates a sequential practice view model for Chinese numbers 0-10
    static func chineseNumbers0to10(env: AppEnvironment) -> SequentialPracticeViewModel {
        let numberCodepoints: [Int] = [
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
        
        let ids = numberCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for Chinese numbers 1-10
    static func chineseNumbers1to10(env: AppEnvironment) -> SequentialPracticeViewModel {
        let numberCodepoints: [Int] = [
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
        
        let ids = numberCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for Chinese numbers 11-19
    static func chineseNumbers11to19(env: AppEnvironment) -> SequentialPracticeViewModel {
        let numbers = Array(11...19)
        let ids = numbers.map { CharacterID(script: .hanzi, codepoint: -$0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for Chinese numbers 20-30
    static func chineseNumbers20to30(env: AppEnvironment) -> SequentialPracticeViewModel {
        let numbers = Array(20...30)
        let ids = numbers.map { CharacterID(script: .hanzi, codepoint: -$0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for all Chinese numbers 1-30
    static func chineseNumbers1to30(env: AppEnvironment) -> SequentialPracticeViewModel {
        // Single numbers 1-10
        let singleNumbers: [Int] = [
            0x4E00, 0x4E8C, 0x4E09, 0x56DB, 0x4E94,
            0x516D, 0x4E03, 0x516B, 0x4E5D, 0x5341
        ]
        
        // Compound numbers 11-30
        let compoundNumbers = Array(11...30).map { -$0 }
        
        let allCodepoints = singleNumbers + compoundNumbers
        let ids = allCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for large numbers (ten, hundred, thousand, etc.)
    static func chineseLargeNumbers(env: AppEnvironment) -> SequentialPracticeViewModel {
        let numberCodepoints: [Int] = [
            0x5341, // 10 (十)
            0x767E, // 100 (百)
            0x5343, // 1000 (千)
            0x4E07, // 10000 (万)
            0x5104  // 100000000 (億)
        ]
        
        let ids = numberCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
}
