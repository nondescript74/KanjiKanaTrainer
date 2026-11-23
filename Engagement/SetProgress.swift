//
//  SetProgress.swift
//  KanjiKanaTrainer
//
//  Ticks and stars on the set lists: which demo sets were watched to the end,
//  how many stars each practice set has earned, and which set is up next.
//

import Foundation

/// Remembers which demo sets were watched to the last character. On this device only.
@MainActor
final class DemoCompletionStore {
    static let shared = DemoCompletionStore()

    private let defaults: UserDefaults
    private static let key = "finishedDemoSets"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var finishedKeys: Set<String> {
        Set(defaults.stringArray(forKey: Self.key) ?? [])
    }

    func isFinished(_ key: String) -> Bool {
        finishedKeys.contains(key)
    }

    func markFinished(_ key: String) {
        var keys = finishedKeys
        guard !keys.contains(key) else { return }
        keys.insert(key)
        defaults.set(keys.sorted(), forKey: Self.key)
    }

    /// Clears all ticks.
    func reset() {
        defaults.removeObject(forKey: Self.key)
    }
}

/// Stars for a best score: 1 from 50%, 2 from 80% (the app's green), 3 from 92%
/// (what a careful redraw of the model scores).
enum StarRating {
    static let maxStars = 3

    static func stars(forBest best: Double) -> Int {
        if best >= 0.92 { return 3 }
        if best >= 0.8 { return 2 }
        if best >= 0.5 { return 1 }
        return 0
    }
}

/// How far a practice set has got.
struct SetProgressSummary: Equatable {
    /// Characters tried at least once.
    let practised: Int
    let total: Int
    /// Stars every character in the set has reached (0 until all are practised).
    let stars: Int

    /// One best score per character in the set; nil for a character never practised.
    init(bestScores: [Double?]) {
        total = bestScores.count
        practised = bestScores.compactMap { $0 }.count
        stars = bestScores.isEmpty ? 0 : bestScores.map { $0.map(StarRating.stars(forBest:)) ?? 0 }.min() ?? 0
    }

    var started: Bool { practised > 0 }
}

/// Best practice score per character, read once from all saved attempts.
struct BestScores {
    private var best: [String: Double] = [:]

    init(_ attempts: [(script: String, codepoint: Int, total: Double)]) {
        for attempt in attempts {
            let key = Self.key(attempt.script, attempt.codepoint)
            best[key] = max(best[key] ?? 0, attempt.total)
        }
    }

    func best(for id: CharacterID) -> Double? {
        best[Self.key(id.script.rawValue, id.codepoint)]
    }

    func summary(for ids: [CharacterID]) -> SetProgressSummary {
        SetProgressSummary(bestScores: ids.map { best(for: $0) })
    }

    private static func key(_ script: String, _ codepoint: Int) -> String {
        "\(script):\(codepoint)"
    }
}

extension BestScores {
    /// Reads every saved attempt from the progress store.
    init(progress: ProgressRepository) {
        let attempts = (try? progress.allAttempts()) ?? []
        self.init(attempts.map { (script: $0.scriptRaw, codepoint: $0.codepoint, total: $0.total) })
    }
}

enum UpNext {
    /// The first set in list order that isn't done yet.
    static func first<Item>(in order: [Item], isDone: (Item) -> Bool) -> Item? {
        order.first { !isDone($0) }
    }
}
