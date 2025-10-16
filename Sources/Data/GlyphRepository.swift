import Foundation

protocol GlyphRepository {
    func glyph(for id: CharacterID) async throws -> CharacterGlyph
}

struct GlyphBundleRepository: GlyphRepository {
    func glyph(for id: CharacterID) async throws -> CharacterGlyph {
        CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: "日",
                       readings: ["にち", "じつ"], meaning: ["sun", "day"],
                       strokes: [], difficulty: 1)
    }
}
