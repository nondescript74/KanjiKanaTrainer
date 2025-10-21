import Foundation

protocol GlyphRepository {
    func glyph(for id: CharacterID) async throws -> CharacterGlyph
    func hasStrokeData(for codepoint: UInt32) -> Bool
}

/// Errors specific to the bundle repository
private enum GlyphBundleError: Error, LocalizedError {
    case missingGlyph(script: Script, codepoint: UInt32)

    var errorDescription: String? {
        switch self {
        case let .missingGlyph(script, codepoint):
            return "No glyph found for script=\(script) codepoint=U+\(String(codepoint, radix: 16).uppercased())"
        }
    }
}

struct GlyphBundleRepository: GlyphRepository {
    // A minimal, embedded bundle of glyph data for the Japanese syllabaries.
    // Keyed by Unicode scalar value (codepoint) per script.
    private static let hiragana: [UInt32: (literal: String, readings: [String])] = {
        var map: [UInt32: (literal: String, readings: [String])] = [:]
        // Core GOJŪON (U+3041..U+3096) including small kana and voiced/p-sounds
        let entries: [(UInt32, String, String)] = [
            (0x3041, "ぁ", "a"), (0x3042, "あ", "a"), (0x3043, "ぃ", "i"), (0x3044, "い", "i"),
            (0x3045, "ぅ", "u"), (0x3046, "う", "u"), (0x3047, "ぇ", "e"), (0x3048, "え", "e"),
            (0x3049, "ぉ", "o"), (0x304A, "お", "o"),
            (0x304B, "か", "ka"), (0x304C, "が", "ga"),
            (0x304D, "き", "ki"), (0x304E, "ぎ", "gi"),
            (0x304F, "く", "ku"), (0x3050, "ぐ", "gu"),
            (0x3051, "け", "ke"), (0x3052, "げ", "ge"),
            (0x3053, "こ", "ko"), (0x3054, "ご", "go"),
            (0x3055, "さ", "sa"), (0x3056, "ざ", "za"),
            (0x3057, "し", "shi"), (0x3058, "じ", "ji"),
            (0x3059, "す", "su"), (0x305A, "ず", "zu"),
            (0x305B, "せ", "se"), (0x305C, "ぜ", "ze"),
            (0x305D, "そ", "so"), (0x305E, "ぞ", "zo"),
            (0x305F, "た", "ta"), (0x3060, "だ", "da"),
            (0x3061, "ち", "chi"), (0x3062, "ぢ", "ji"),
            (0x3064, "つ", "tsu"), (0x3065, "づ", "zu"),
            (0x3063, "っ", "tsu"),
            (0x3066, "て", "te"), (0x3067, "で", "de"),
            (0x3068, "と", "to"), (0x3069, "ど", "do"),
            (0x306A, "な", "na"), (0x306B, "に", "ni"), (0x306C, "ぬ", "nu"), (0x306D, "ね", "ne"), (0x306E, "の", "no"),
            (0x306F, "は", "ha"), (0x3070, "ば", "ba"), (0x3071, "ぱ", "pa"),
            (0x3072, "ひ", "hi"), (0x3073, "び", "bi"), (0x3074, "ぴ", "pi"),
            (0x3075, "ふ", "fu"), (0x3076, "ぶ", "bu"), (0x3077, "ぷ", "pu"),
            (0x3078, "へ", "he"), (0x3079, "べ", "be"), (0x307A, "ぺ", "pe"),
            (0x307B, "ほ", "ho"), (0x307C, "ぼ", "bo"), (0x307D, "ぽ", "po"),
            (0x307E, "ま", "ma"), (0x307F, "み", "mi"), (0x3080, "む", "mu"), (0x3081, "め", "me"), (0x3082, "も", "mo"),
            (0x3083, "ゃ", "ya"), (0x3084, "や", "ya"), (0x3085, "ゅ", "yu"), (0x3086, "ゆ", "yu"), (0x3087, "ょ", "yo"), (0x3088, "よ", "yo"),
            (0x3089, "ら", "ra"), (0x308A, "り", "ri"), (0x308B, "る", "ru"), (0x308C, "れ", "re"), (0x308D, "ろ", "ro"),
            (0x308E, "ゎ", "wa"), (0x308F, "わ", "wa"), (0x3090, "ゐ", "wi"), (0x3091, "ゑ", "we"), (0x3092, "を", "wo"),
            (0x3093, "ん", "n"), (0x3094, "ゔ", "vu"), (0x3095, "ゕ", "ka"), (0x3096, "ゖ", "ke")
        ]
        for (s, lit, rom) in entries {
            map[s] = (literal: lit, readings: [rom])
        }
        return map
    }()

    private static let katakana: [UInt32: (literal: String, readings: [String])] = {
        var map: [UInt32: (literal: String, readings: [String])] = [:]
        let entries: [(UInt32, String, String)] = [
            (0x30A1, "ァ", "a"), (0x30A2, "ア", "a"), (0x30A3, "ィ", "i"), (0x30A4, "イ", "i"),
            (0x30A5, "ゥ", "u"), (0x30A6, "ウ", "u"), (0x30A7, "ェ", "e"), (0x30A8, "エ", "e"),
            (0x30A9, "ォ", "o"), (0x30AA, "オ", "o"),
            (0x30AB, "カ", "ka"), (0x30AC, "ガ", "ga"),
            (0x30AD, "キ", "ki"), (0x30AE, "ギ", "gi"),
            (0x30AF, "ク", "ku"), (0x30B0, "グ", "gu"),
            (0x30B1, "ケ", "ke"), (0x30B2, "ゲ", "ge"),
            (0x30B3, "コ", "ko"), (0x30B4, "ゴ", "go"),
            (0x30B5, "サ", "sa"), (0x30B6, "ザ", "za"),
            (0x30B7, "シ", "shi"), (0x30B8, "ジ", "ji"),
            (0x30B9, "ス", "su"), (0x30BA, "ズ", "zu"),
            (0x30BB, "セ", "se"), (0x30BC, "ゼ", "ze"),
            (0x30BD, "ソ", "so"), (0x30BE, "ゾ", "zo"),
            (0x30BF, "タ", "ta"), (0x30C0, "ダ", "da"),
            (0x30C1, "チ", "chi"), (0x30C2, "ヂ", "ji"),
            (0x30C3, "ッ", "tsu"), (0x30C4, "ツ", "tsu"), (0x30C5, "ヅ", "zu"),
            (0x30C6, "テ", "te"), (0x30C7, "デ", "de"),
            (0x30C8, "ト", "to"), (0x30C9, "ド", "do"),
            (0x30CA, "ナ", "na"), (0x30CB, "ニ", "ni"), (0x30CC, "ヌ", "nu"), (0x30CD, "ネ", "ne"), (0x30CE, "ノ", "no"),
            (0x30CF, "ハ", "ha"), (0x30D0, "バ", "ba"), (0x30D1, "パ", "pa"),
            (0x30D2, "ヒ", "hi"), (0x30D3, "ビ", "bi"), (0x30D4, "ピ", "pi"),
            (0x30D5, "フ", "fu"), (0x30D6, "ブ", "bu"), (0x30D7, "プ", "pu"),
            (0x30D8, "ヘ", "he"), (0x30D9, "ベ", "be"), (0x30DA, "ペ", "pe"),
            (0x30DB, "ホ", "ho"), (0x30DC, "ボ", "bo"), (0x30DD, "ポ", "po"),
            (0x30DE, "マ", "ma"), (0x30DF, "ミ", "mi"), (0x30E0, "ム", "mu"), (0x30E1, "メ", "me"), (0x30E2, "モ", "mo"),
            (0x30E3, "ャ", "ya"), (0x30E4, "ヤ", "ya"), (0x30E5, "ュ", "yu"), (0x30E6, "ユ", "yu"), (0x30E7, "ョ", "yo"), (0x30E8, "ヨ", "yo"),
            (0x30E9, "ラ", "ra"), (0x30EA, "リ", "ri"), (0x30EB, "ル", "ru"), (0x30EC, "レ", "re"), (0x30ED, "ロ", "ro"),
            (0x30EE, "ヮ", "wa"), (0x30EF, "ワ", "wa"), (0x30F0, "ヰ", "wi"), (0x30F1, "ヱ", "we"), (0x30F2, "ヲ", "wo"),
            (0x30F3, "ン", "n"), (0x30F4, "ヴ", "vu"), (0x30F5, "ヵ", "ka"), (0x30F6, "ヶ", "ke")
        ]
        for (s, lit, rom) in entries {
            map[s] = (literal: lit, readings: [rom])
        }
        return map
    }()

    func glyph(for id: CharacterID) async throws -> CharacterGlyph {
        // Look up by codepoint in both syllabary maps, independent of Script enum details.
        if let payload = Self.hiragana[UInt32(id.codepoint)] {
            // Load stroke data from JSON on-demand
            let strokes = StrokeDataLoader.loadStrokes(for: UInt32(id.codepoint)) ?? []
            return CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: payload.literal, readings: payload.readings, meaning: [], strokes: strokes, difficulty: 1)
        }
        if let payload = Self.katakana[UInt32(id.codepoint)] {
            // Load stroke data from JSON on-demand
            let strokes = StrokeDataLoader.loadStrokes(for: UInt32(id.codepoint)) ?? []
            return CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: payload.literal, readings: payload.readings, meaning: [], strokes: strokes, difficulty: 1)
        }
        throw GlyphBundleError.missingGlyph(script: id.script, codepoint: UInt32(id.codepoint))
    }
    
    /// Check if stroke data is available for a specific codepoint
    func hasStrokeData(for codepoint: UInt32) -> Bool {
        return StrokeDataLoader.loadStrokes(for: codepoint) != nil
    }
//    /// Check if stroke data is available for a specific codepoint
//    func hasStrokeData(for codepoint: UInt32) -> Bool {
//        return StrokeDataLoader.loadStrokes(for: codepoint) != nil
//    }
}
