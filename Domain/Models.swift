import Foundation

enum Script: String, Codable { case kana, kanji, hanzi }

struct CharacterID: Hashable, Codable {
    let script: Script
    let codepoint: Int
}

struct StrokePoint: Codable { let x: Float; let y: Float; let t: TimeInterval }
struct StrokePath: Codable { let points: [StrokePoint] }

struct CharacterGlyph: Codable, Identifiable {
    var id: CharacterID { .init(script: script, codepoint: codepoint) }
    let script: Script
    let codepoint: Int
    let literal: String
    let readings: [String]
    let meaning: [String]
    let strokes: [StrokePath]
    let difficulty: Int
}

struct PracticeScore: Codable {
    let orderAccuracy: Double
    let shapeSimilarity: Double
    var total: Double { (orderAccuracy + shapeSimilarity) / 2.0 }
}
