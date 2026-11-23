import Foundation
import Testing
@testable import KanjiKanaTrainer

/// A seeded random source so quiz tests repeat exactly.
private struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// Number game rules.
@MainActor
struct NumberGameTests {

    private let repo = GlyphBundleRepository()

    @Test func numeralsMatchTheNumberSets() async throws {
        for n in 0...100 {
            let literal = try await repo.glyph(for: ChineseNumberIDs.id(for: n)).literal
            #expect(ChineseNumerals.literal(for: n) == literal, "number \(n)")
        }
    }

    @Test func numeralsReadTheUsualWay() {
        #expect(ChineseNumerals.literal(for: 7) == "七")
        #expect(ChineseNumerals.literal(for: 11) == "十一")
        #expect(ChineseNumerals.literal(for: 20) == "二十")
        #expect(ChineseNumerals.literal(for: 73) == "七十三")
        #expect(ChineseNumerals.literal(for: 100) == "一百")
    }

    @Test func swappedDigitsComeFirst() {
        #expect(NumberQuiz.lookAlikes(for: 73, in: 1...100).first == 37)
        #expect(NumberQuiz.lookAlikes(for: 73, in: 1...100).contains(63))
        #expect(!NumberQuiz.lookAlikes(for: 33, in: 1...100).contains(33))
        #expect(NumberQuiz.lookAlikes(for: 10, in: 1...10) == [9])
    }

    @Test func questionsAreFair() {
        for range in NumberGameRange.allCases {
            for seed in 0..<200 {
                var rng = SplitMix64(state: UInt64(seed))
                let q = NumberQuiz.question(in: range.numbers, using: &rng)
                #expect(q.choices.count == 4)
                #expect(q.choices.contains(q.answer))
                #expect(Set(q.choices).count == q.choices.count)
                #expect(q.choices.allSatisfy { range.numbers.contains($0) })
            }
        }
    }

    @Test func neverTheSameNumberTwiceInARow() {
        var rng = SplitMix64(state: 42)
        var previous = 5
        for _ in 0..<200 {
            let q = NumberQuiz.question(in: 1...10, avoiding: previous, using: &rng)
            #expect(q.answer != previous)
            previous = q.answer
        }
    }

    @Test func streaksAndBestAreKept() throws {
        let defaults = try #require(UserDefaults(suiteName: "NumberGameTests.\(UUID().uuidString)"))
        let model = NumberGameViewModel(defaults: defaults)
        model.pick(model.question.answer)
        #expect(model.answeredRight)
        #expect(model.streak == 1)
        #expect(model.bestStreak == 1)
        model.next()
        let wrong = try #require(model.question.choices.first { $0 != model.question.answer })
        model.pick(wrong)
        #expect(model.streak == 0)
        #expect(model.correctCount == 1)
        #expect(model.answeredCount == 2)
        #expect(NumberGameViewModel(defaults: defaults).bestStreak == 1)
        model.stop()
    }
}

/// Family tree data.
@MainActor
struct FamilyTreeTests {

    @Test func everyRelativeCanBeDrawn() async throws {
        let repo = GlyphBundleRepository()
        for member in FamilyTree.allMembers {
            #expect(!member.glyphIDs.isEmpty, "\(member.word)")
            for id in member.glyphIDs {
                let glyph = try await repo.glyph(for: id)
                #expect(!glyph.strokes.isEmpty, "\(member.word): \(glyph.literal) has no strokes")
            }
        }
    }

    @Test func repeatedCharactersAreDrawnOnce() {
        #expect(FamilyMember(word: "爸爸", pinyin: "bàba", english: "Dad").codepoints == [0x7238])
        #expect(FamilyMember(word: "外婆", pinyin: "wàipó", english: "Grandma").codepoints == [0x5916, 0x5A46])
    }

    @Test func wordsAreUnique() {
        let words = FamilyTree.allMembers.map(\.word)
        #expect(Set(words).count == words.count)
    }
}

/// Ticks, stars and "Up next".
@MainActor
struct SetProgressTests {

    @Test func starThresholds() {
        #expect(StarRating.stars(forBest: 0.0) == 0)
        #expect(StarRating.stars(forBest: 0.49) == 0)
        #expect(StarRating.stars(forBest: 0.5) == 1)
        #expect(StarRating.stars(forBest: 0.8) == 2)
        #expect(StarRating.stars(forBest: 0.92) == 3)
        #expect(StarRating.stars(forBest: 1.0) == 3)
    }

    @Test func aSetHasTheStarsOfItsWeakestCharacter() {
        let full = SetProgressSummary(bestScores: [0.95, 0.85, 0.6])
        #expect(full.stars == 1)
        #expect(full.practised == 3)
        #expect(full.total == 3)

        let partial = SetProgressSummary(bestScores: [0.95, nil])
        #expect(partial.stars == 0)
        #expect(partial.practised == 1)
        #expect(partial.started)

        let empty = SetProgressSummary(bestScores: [])
        #expect(empty.stars == 0)
        #expect(!empty.started)
    }

    @Test func bestScoreIsTheHighest() {
        let a = CharacterID(script: .hanzi, codepoint: 0x4E00)
        let b = CharacterID(script: .hanzi, codepoint: -73)
        let bests = BestScores([
            (script: "hanzi", codepoint: 0x4E00, total: 0.4),
            (script: "hanzi", codepoint: 0x4E00, total: 0.9),
            (script: "hanzi", codepoint: 0x4E00, total: 0.7),
            (script: "kana", codepoint: -73, total: 1.0),
        ])
        #expect(bests.best(for: a) == 0.9)
        #expect(bests.best(for: b) == nil)
        #expect(bests.summary(for: [a, b]) == SetProgressSummary(bestScores: [0.9, nil]))
    }

    @Test func demoTicksAreRemembered() throws {
        let defaults = try #require(UserDefaults(suiteName: "SetProgressTests.\(UUID().uuidString)"))
        let store = DemoCompletionStore(defaults: defaults)
        #expect(!store.isFinished("chinese.demo.family"))
        store.markFinished("chinese.demo.family")
        store.markFinished("chinese.demo.family")
        #expect(DemoCompletionStore(defaults: defaults).finishedKeys == ["chinese.demo.family"])
        store.reset()
        #expect(store.finishedKeys.isEmpty)
    }

    @Test func upNextIsTheFirstUndoneSet() {
        #expect(UpNext.first(in: [1, 2, 3]) { $0 < 2 } == 2)
        #expect(UpNext.first(in: [1, 2, 3]) { _ in true } == nil)
    }

    @Test func upNextListsHaveNoRepeats() {
        let practice = ChineseNumberSetSelector.NumberSet.upNextOrder
        #expect(Set(practice).count == practice.count)
        let demos = ChineseDemoSetSelector.DemoSet.upNextOrder
        #expect(Set(demos).count == demos.count)
    }
}
