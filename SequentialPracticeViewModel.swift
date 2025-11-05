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
    
    // MARK: - Chinese Common Characters (100 characters)
    
    /// Body Parts & People (8 characters)
    static func chineseBodyParts(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Nature & Elements (17 characters)
    static func chineseNature(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Size & Direction (11 characters)
    static func chineseSizeDirection(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Common Objects & Animals (18 characters)
    static func chineseObjects(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Pronouns & Common Words (10 characters)
    static func chinesePronouns(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// Common Verbs (18 characters)
    static func chineseVerbs(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// More Common Words (8 characters)
    static func chineseCommonWords(env: AppEnvironment) -> SequentialPracticeViewModel {
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
        return SequentialPracticeViewModel(glyphIDs: ids, env: env)
    }
    
    /// All 100 Common Characters
    static func chineseCommonAll(env: AppEnvironment) -> SequentialPracticeViewModel {
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
