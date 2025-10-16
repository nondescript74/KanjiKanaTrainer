import Foundation
import Combine

@MainActor
final class LessonViewModel: ObservableObject {
    @Published var glyph: CharacterGlyph?
    private let env: AppEnvironment
    private let glyphID: CharacterID

    init(id: CharacterID, env: AppEnvironment) {
        self.glyphID = id
        self.env = env
    }

    func loadGlyph() async {
        do {
            glyph = try await env.glyphs.glyph(for: glyphID)
        } catch {
            print("Failed to load glyph: \(error)")
        }
    }

    func startPractice() { }
}
