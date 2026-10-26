import Foundation
import SwiftData

/// One scored practice attempt, kept on the device.
@Model
final class PracticeAttempt {
    var scriptRaw: String
    var codepoint: Int
    var literal: String
    var orderAccuracy: Double
    var shapeSimilarity: Double
    var total: Double
    var date: Date

    init(glyph: CharacterGlyph, score: PracticeScore, date: Date = .now) {
        self.scriptRaw = glyph.script.rawValue
        self.codepoint = glyph.codepoint
        self.literal = glyph.literal
        self.orderAccuracy = score.orderAccuracy
        self.shapeSimilarity = score.shapeSimilarity
        self.total = score.total
        self.date = date
    }
}

/// What has been practised, per character.
struct CharacterProgress: Equatable {
    let literal: String
    let attempts: Int
    let bestScore: Double
    let lastPracticed: Date
}

@MainActor
protocol ProgressRepository {
    /// Records one scored attempt.
    func record(glyph: CharacterGlyph, score: PracticeScore) throws
    /// Progress for one character, or nil if it has never been practised.
    func progress(for id: CharacterID) throws -> CharacterProgress?
    /// Every attempt, newest first.
    func allAttempts() throws -> [PracticeAttempt]
    /// Removes all saved progress.
    func reset() throws
}

/// Saves attempts with SwiftData in the app's own container: on the device only,
/// no account and no server.
@MainActor
final class SwiftDataProgressStore: ProgressRepository {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    /// - Parameter inMemory: true for tests and previews.
    init(inMemory: Bool = false) {
        let config = ModelConfiguration("Progress", isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: PracticeAttempt.self, configurations: config)
        } catch {
            // A broken store must not stop the child from practising:
            // fall back to an in-memory store for this run.
            print("⚠️ Progress store unavailable (\(error)); using memory only this session")
            let memory = ModelConfiguration("ProgressFallback", isStoredInMemoryOnly: true)
            container = try! ModelContainer(for: PracticeAttempt.self, configurations: memory)
        }
    }

    func record(glyph: CharacterGlyph, score: PracticeScore) throws {
        context.insert(PracticeAttempt(glyph: glyph, score: score))
        try context.save()
    }

    func progress(for id: CharacterID) throws -> CharacterProgress? {
        let script = id.script.rawValue
        let codepoint = id.codepoint
        let descriptor = FetchDescriptor<PracticeAttempt>(
            predicate: #Predicate { $0.scriptRaw == script && $0.codepoint == codepoint },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let attempts = try context.fetch(descriptor)
        guard let latest = attempts.first else { return nil }
        return CharacterProgress(
            literal: latest.literal,
            attempts: attempts.count,
            bestScore: attempts.map(\.total).max() ?? 0,
            lastPracticed: latest.date
        )
    }

    func allAttempts() throws -> [PracticeAttempt] {
        try context.fetch(FetchDescriptor<PracticeAttempt>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
    }

    func reset() throws {
        try context.delete(model: PracticeAttempt.self)
        try context.save()
    }
}
