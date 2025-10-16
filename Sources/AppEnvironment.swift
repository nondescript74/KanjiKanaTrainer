import Foundation
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    let glyphs: GlyphRepository
    let progress: ProgressRepository
    let evaluator: AttemptEvaluator

    init(glyphs: GlyphRepository, progress: ProgressRepository, evaluator: AttemptEvaluator) {
        self.glyphs = glyphs
        self.progress = progress
        self.evaluator = evaluator
    }

    static func live() -> AppEnvironment {
        AppEnvironment(glyphs: GlyphBundleRepository(), progress: SwiftDataProgressStore(), evaluator: DefaultAttemptEvaluator())
    }
}
