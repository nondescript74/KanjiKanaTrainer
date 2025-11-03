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
        // Numbers 11-19 are formed by combining 十 (10) + number
        // 十一 (11), 十二 (12), etc.
        let baseCodepoints: [Int] = [
            0x5341, // 十 (10)
            0x4E00, // 一 (1)
            0x4E8C, // 二 (2)
            0x4E09, // 三 (3)
            0x56DB, // 四 (4)
            0x4E94, // 五 (5)
            0x516D, // 六 (6)
            0x4E03, // 七 (7)
            0x516B, // 八 (8)
            0x4E5D  // 九 (9)
        ]
        
        // For sequential practice, we'll use the base digits
        let ids = baseCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for Chinese numbers 20-30
    static func chineseNumbers20to30(env: AppEnvironment) -> SequentialPracticeViewModel {
        // Numbers 20-30 use: 二十 (20), 二十一 (21), ... 三十 (30)
        let baseCodepoints: [Int] = [
            0x4E8C, // 二 (2)
            0x5341, // 十 (10)
            0x4E00, // 一 (1)
            0x4E09, // 三 (3)
            0x56DB, // 四 (4)
            0x4E94, // 五 (5)
            0x516D, // 六 (6)
            0x4E03, // 七 (7)
            0x516B, // 八 (8)
            0x4E5D, // 九 (9)
        ]
        
        let ids = baseCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for Chinese numbers 1-30
    static func chineseNumbers1to30(env: AppEnvironment) -> SequentialPracticeViewModel {
        // All unique characters needed for numbers 1-30
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
    
    /// Creates a sequential practice view model for large Chinese numbers
    static func chineseLargeNumbers(env: AppEnvironment) -> SequentialPracticeViewModel {
        let numberCodepoints: [Int] = [
            0x5341, // 十 (10)
            0x767E, // 百 (100)
            0x5343, // 千 (1,000)
            0x4E07, // 万 (10,000)
            0x5104  // 億 (100,000,000)
        ]
        
        let ids = numberCodepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    // MARK: - Hiragana Sets
    
    /// Creates a sequential practice view model for basic Hiragana vowels (a, i, u, e, o)
    static func hiraganaVowels(env: AppEnvironment) -> SequentialPracticeViewModel {
        let vowelCodepoints: [Int] = [
            0x3042, // あ (a)
            0x3044, // い (i)
            0x3046, // う (u)
            0x3048, // え (e)
            0x304A  // お (o)
        ]
        
        let ids = vowelCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the K-row (ka, ki, ku, ke, ko)
    static func hiraganaKRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let kRowCodepoints: [Int] = [
            0x304B, // か (ka)
            0x304D, // き (ki)
            0x304F, // く (ku)
            0x3051, // け (ke)
            0x3053  // こ (ko)
        ]
        
        let ids = kRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the S-row (sa, shi, su, se, so)
    static func hiraganaSRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let sRowCodepoints: [Int] = [
            0x3055, // さ (sa)
            0x3057, // し (shi)
            0x3059, // す (su)
            0x305B, // せ (se)
            0x305D  // そ (so)
        ]
        
        let ids = sRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the T-row (ta, chi, tsu, te, to)
    static func hiraganaTRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let tRowCodepoints: [Int] = [
            0x305F, // た (ta)
            0x3061, // ち (chi)
            0x3064, // つ (tsu)
            0x3066, // て (te)
            0x3068  // と (to)
        ]
        
        let ids = tRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the N-row (na, ni, nu, ne, no)
    static func hiraganaNRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let nRowCodepoints: [Int] = [
            0x306A, // な (na)
            0x306B, // に (ni)
            0x306C, // ぬ (nu)
            0x306D, // ね (ne)
            0x306E  // の (no)
        ]
        
        let ids = nRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the H-row (ha, hi, fu, he, ho)
    static func hiraganaHRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let hRowCodepoints: [Int] = [
            0x306F, // は (ha)
            0x3072, // ひ (hi)
            0x3075, // ふ (fu)
            0x3078, // へ (he)
            0x307B  // ほ (ho)
        ]
        
        let ids = hRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the M-row (ma, mi, mu, me, mo)
    static func hiraganaMRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let mRowCodepoints: [Int] = [
            0x307E, // ま (ma)
            0x307F, // み (mi)
            0x3080, // む (mu)
            0x3081, // め (me)
            0x3082  // も (mo)
        ]
        
        let ids = mRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the Y-row (ya, yu, yo)
    static func hiraganaYRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let yRowCodepoints: [Int] = [
            0x3084, // や (ya)
            0x3086, // ゆ (yu)
            0x3088  // よ (yo)
        ]
        
        let ids = yRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the R-row (ra, ri, ru, re, ro)
    static func hiraganaRRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let rRowCodepoints: [Int] = [
            0x3089, // ら (ra)
            0x308A, // り (ri)
            0x308B, // る (ru)
            0x308C, // れ (re)
            0x308D  // ろ (ro)
        ]
        
        let ids = rRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for W-row and N (wa, wo, n)
    static func hiraganaWRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let wRowCodepoints: [Int] = [
            0x308F, // わ (wa)
            0x3092, // を (wo)
            0x3093  // ん (n)
        ]
        
        let ids = wRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for all basic Hiragana (46 characters)
    static func hiraganaComplete(env: AppEnvironment) -> SequentialPracticeViewModel {
        let allHiragana: [Int] = [
            // Vowels
            0x3042, 0x3044, 0x3046, 0x3048, 0x304A,
            // K-row
            0x304B, 0x304D, 0x304F, 0x3051, 0x3053,
            // S-row
            0x3055, 0x3057, 0x3059, 0x305B, 0x305D,
            // T-row
            0x305F, 0x3061, 0x3064, 0x3066, 0x3068,
            // N-row
            0x306A, 0x306B, 0x306C, 0x306D, 0x306E,
            // H-row
            0x306F, 0x3072, 0x3075, 0x3078, 0x307B,
            // M-row
            0x307E, 0x307F, 0x3080, 0x3081, 0x3082,
            // Y-row
            0x3084, 0x3086, 0x3088,
            // R-row
            0x3089, 0x308A, 0x308B, 0x308C, 0x308D,
            // W-row and N
            0x308F, 0x3092, 0x3093
        ]
        
        let ids = allHiragana.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    // MARK: - Katakana Sets
    
    /// Creates a sequential practice view model for basic Katakana vowels (a, i, u, e, o)
    static func katakanaVowels(env: AppEnvironment) -> SequentialPracticeViewModel {
        let vowelCodepoints: [Int] = [
            0x30A2, // ア (a)
            0x30A4, // イ (i)
            0x30A6, // ウ (u)
            0x30A8, // エ (e)
            0x30AA  // オ (o)
        ]
        
        let ids = vowelCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the K-row (ka, ki, ku, ke, ko)
    static func katakanaKRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let kRowCodepoints: [Int] = [
            0x30AB, // カ (ka)
            0x30AD, // キ (ki)
            0x30AF, // ク (ku)
            0x30B1, // ケ (ke)
            0x30B3  // コ (ko)
        ]
        
        let ids = kRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the S-row (sa, shi, su, se, so)
    static func katakanaSRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let sRowCodepoints: [Int] = [
            0x30B5, // サ (sa)
            0x30B7, // シ (shi)
            0x30B9, // ス (su)
            0x30BB, // セ (se)
            0x30BD  // ソ (so)
        ]
        
        let ids = sRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the T-row (ta, chi, tsu, te, to)
    static func katakanaTRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let tRowCodepoints: [Int] = [
            0x30BF, // タ (ta)
            0x30C1, // チ (chi)
            0x30C4, // ツ (tsu)
            0x30C6, // テ (te)
            0x30C8  // ト (to)
        ]
        
        let ids = tRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the N-row (na, ni, nu, ne, no)
    static func katakanaNRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let nRowCodepoints: [Int] = [
            0x30CA, // ナ (na)
            0x30CB, // ニ (ni)
            0x30CC, // ヌ (nu)
            0x30CD, // ネ (ne)
            0x30CE  // ノ (no)
        ]
        
        let ids = nRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the H-row (ha, hi, fu, he, ho)
    static func katakanaHRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let hRowCodepoints: [Int] = [
            0x30CF, // ハ (ha)
            0x30D2, // ヒ (hi)
            0x30D5, // フ (fu)
            0x30D8, // ヘ (he)
            0x30DB  // ホ (ho)
        ]
        
        let ids = hRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the M-row (ma, mi, mu, me, mo)
    static func katakanaMRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let mRowCodepoints: [Int] = [
            0x30DE, // マ (ma)
            0x30DF, // ミ (mi)
            0x30E0, // ム (mu)
            0x30E1, // メ (me)
            0x30E2  // モ (mo)
        ]
        
        let ids = mRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the Y-row (ya, yu, yo)
    static func katakanaYRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let yRowCodepoints: [Int] = [
            0x30E4, // ヤ (ya)
            0x30E6, // ユ (yu)
            0x30E8  // ヨ (yo)
        ]
        
        let ids = yRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for the R-row (ra, ri, ru, re, ro)
    static func katakanaRRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let rRowCodepoints: [Int] = [
            0x30E9, // ラ (ra)
            0x30EA, // リ (ri)
            0x30EB, // ル (ru)
            0x30EC, // レ (re)
            0x30ED  // ロ (ro)
        ]
        
        let ids = rRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for W-row and N (wa, wo, n)
    static func katakanaWRow(env: AppEnvironment) -> SequentialPracticeViewModel {
        let wRowCodepoints: [Int] = [
            0x30EF, // ワ (wa)
            0x30F2, // ヲ (wo)
            0x30F3  // ン (n)
        ]
        
        let ids = wRowCodepoints.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Creates a sequential practice view model for all basic Katakana (46 characters)
    static func katakanaComplete(env: AppEnvironment) -> SequentialPracticeViewModel {
        let allKatakana: [Int] = [
            // Vowels
            0x30A2, 0x30A4, 0x30A6, 0x30A8, 0x30AA,
            // K-row
            0x30AB, 0x30AD, 0x30AF, 0x30B1, 0x30B3,
            // S-row
            0x30B5, 0x30B7, 0x30B9, 0x30BB, 0x30BD,
            // T-row
            0x30BF, 0x30C1, 0x30C4, 0x30C6, 0x30C8,
            // N-row
            0x30CA, 0x30CB, 0x30CC, 0x30CD, 0x30CE,
            // H-row
            0x30CF, 0x30D2, 0x30D5, 0x30D8, 0x30DB,
            // M-row
            0x30DE, 0x30DF, 0x30E0, 0x30E1, 0x30E2,
            // Y-row
            0x30E4, 0x30E6, 0x30E8,
            // R-row
            0x30E9, 0x30EA, 0x30EB, 0x30EC, 0x30ED,
            // W-row and N
            0x30EF, 0x30F2, 0x30F3
        ]
        
        let ids = allKatakana.map { CharacterID(script: .kana, codepoint: $0) }
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
}
