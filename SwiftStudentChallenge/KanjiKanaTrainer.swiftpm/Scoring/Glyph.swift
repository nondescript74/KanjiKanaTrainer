import Foundation

struct StrokePoint: Codable, Hashable { let x: Double; let y: Double }
struct StrokePath: Codable, Hashable { let points: [StrokePoint] }

/// One character with its reference strokes in a 0–1 box, y pointing down.
struct Glyph: Identifiable, Hashable {
    var id: String { literal }
    let literal: String
    let pinyin: String
    let meaning: String
    let strokes: [StrokePath]
}

enum GlyphLibrary {
    private struct Raw: Decodable {
        let literal: String
        let pinyin: String
        let meaning: String
        let strokes: [[[Double]]]
    }

    /// The three characters used in the guided flow, loaded from the bundled JSON.
    static let all: [Glyph] = {
        guard let url = Bundle.main.url(forResource: "glyphs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let raw = try? JSONDecoder().decode([Raw].self, from: data) else { return [] }
        return raw.map { r in
            Glyph(literal: r.literal, pinyin: r.pinyin, meaning: r.meaning,
                  strokes: r.strokes.map { StrokePath(points: $0.map { StrokePoint(x: $0[0], y: $0[1]) }) })
        }
    }()

    static func glyph(_ literal: String) -> Glyph? { all.first { $0.literal == literal } }
}
