import Foundation

enum Script: String, Codable { case kana, kanji, hanzi }

struct CharacterID: Hashable, Codable {
    let script: Script
    let codepoint: Int
    
    // Special constructor for compound characters using negative codepoints
    static func compound(script: Script, number: Int) -> CharacterID {
        return CharacterID(script: script, codepoint: -number)
    }
    
    var isCompound: Bool {
        return codepoint < 0
    }
    
    var compoundNumber: Int? {
        return isCompound ? -codepoint : nil
    }
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
    
    // Optional: component characters for compound numbers
    let components: [Int]?
    
    // Check if this is a compound character
    var isCompound: Bool {
        return components != nil && !components!.isEmpty
    }
}

struct PracticeScore: Codable {
    let orderAccuracy: Double
    let shapeSimilarity: Double
    var total: Double { (orderAccuracy + shapeSimilarity) / 2.0 }
}
