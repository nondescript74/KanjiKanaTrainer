//
//  NumberGame.swift
//  KanjiKanaTrainer
//
//  Number game: hear or see a Chinese number and tap the matching one.
//  The rules live here, apart from the screen, so they can be tested.
//

import Foundation
import Combine

/// Which voice says the Chinese: Mandarin or Cantonese (Hong Kong).
enum ChineseVoice: String, CaseIterable, Identifiable {
    case mandarin
    case cantonese

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mandarin: return "Mandarin"
        case .cantonese: return "Cantonese"
        }
    }

    /// Speech voice language for AVSpeechSynthesisVoice.
    var language: String {
        switch self {
        case .mandarin: return "zh-CN"
        case .cantonese: return "zh-HK"
        }
    }
}

/// Chinese numerals 0-100, written the way the app's number sets write them
/// (十一 for 11, 二十 for 20, 一百 for 100).
enum ChineseNumerals {
    static let digits = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]

    static func literal(for number: Int) -> String {
        precondition((0...100).contains(number), "Chinese numerals here cover 0-100")
        if number == 100 { return "一百" }
        if number < 10 { return digits[number] }
        let tens = number / 10
        let ones = number % 10
        var text = tens == 1 ? "" : digits[tens]
        text += "十"
        if ones > 0 { text += digits[ones] }
        return text
    }
}

/// How the question is asked.
enum NumberGameMode: String, CaseIterable, Identifiable {
    /// Hear 七十三, tap 73.
    case listen
    /// See 七十三, tap 73.
    case read
    /// See 73, tap 七十三.
    case find

    var id: String { rawValue }

    var title: String {
        switch self {
        case .listen: return "Listen"
        case .read: return "Read"
        case .find: return "Find"
        }
    }

    var instruction: String {
        switch self {
        case .listen: return "Listen, then tap the number you hear."
        case .read: return "Tap the number this says."
        case .find: return "Tap this number in Chinese."
        }
    }

    /// True when the answer buttons show Chinese rather than digits.
    var choicesInChinese: Bool { self == .find }
}

/// Which numbers the game uses.
enum NumberGameRange: String, CaseIterable, Identifiable {
    case upTo10
    case upTo30
    case upTo100

    var id: String { rawValue }

    var title: String {
        switch self {
        case .upTo10: return "1-10"
        case .upTo30: return "1-30"
        case .upTo100: return "1-100"
        }
    }

    var numbers: ClosedRange<Int> {
        switch self {
        case .upTo10: return 1...10
        case .upTo30: return 1...30
        case .upTo100: return 1...100
        }
    }
}

/// One question: the right answer and the buttons to choose from.
struct NumberQuestion: Equatable {
    let answer: Int
    /// Includes the answer, in the order the buttons show them.
    let choices: [Int]
}

enum NumberQuiz {

    /// Numbers that are easy to mix up with `answer`, most confusing first:
    /// digits swapped (73 and 37), the same ones digit ten away (63, 83), one either side (72, 74).
    static func lookAlikes(for answer: Int, in range: ClosedRange<Int>) -> [Int] {
        var candidates: [Int] = []
        let tens = answer / 10
        let ones = answer % 10
        if answer >= 11, answer <= 99, ones != 0, ones != tens {
            candidates.append(ones * 10 + tens)
        }
        candidates += [answer - 10, answer + 10, answer - 1, answer + 1]
        var seen: Set<Int> = [answer]
        var out: [Int] = []
        for n in candidates where range.contains(n) && !seen.contains(n) {
            seen.insert(n)
            out.append(n)
        }
        return out
    }

    /// A question with `choiceCount` different choices from `range`, one of them right.
    /// Two of the wrong choices are look-alikes where there are any, so the game teaches
    /// the difference between 七十三 and 三十七 rather than being guessable.
    static func question<G: RandomNumberGenerator>(
        in range: ClosedRange<Int>,
        choiceCount: Int = 4,
        avoiding previous: Int? = nil,
        using generator: inout G
    ) -> NumberQuestion {
        let count = min(choiceCount, range.count)
        var answer = Int.random(in: range, using: &generator)
        if let previous, range.count > 1, answer == previous {
            // Don't ask the same number twice in a row.
            answer = answer == range.upperBound ? range.lowerBound : answer + 1
        }

        var choices: [Int] = [answer]
        for n in lookAlikes(for: answer, in: range).shuffled(using: &generator).prefix(2) where choices.count < count {
            choices.append(n)
        }
        while choices.count < count {
            let n = Int.random(in: range, using: &generator)
            if !choices.contains(n) { choices.append(n) }
        }
        return NumberQuestion(answer: answer, choices: choices.shuffled(using: &generator))
    }
}

/// State for the number game screen.
@MainActor
final class NumberGameViewModel: ObservableObject {
    @Published var mode: NumberGameMode = .listen {
        didSet { if mode != oldValue { restart() } }
    }
    @Published var range: NumberGameRange = .upTo10 {
        didSet { if range != oldValue { restart() } }
    }
    @Published var voice: ChineseVoice = .mandarin

    @Published private(set) var question: NumberQuestion
    /// The choice tapped for this question, or nil before a tap.
    @Published private(set) var picked: Int?
    @Published private(set) var streak = 0
    @Published private(set) var correctCount = 0
    @Published private(set) var answeredCount = 0
    @Published private(set) var bestStreak: Int

    private let defaults: UserDefaults
    private static let bestStreakKey = "numberGameBestStreak"
    private var generator = SystemRandomNumberGenerator()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.bestStreak = defaults.integer(forKey: Self.bestStreakKey)
        var generator = SystemRandomNumberGenerator()
        self.question = NumberQuiz.question(in: NumberGameRange.upTo10.numbers, using: &generator)
    }

    var answered: Bool { picked != nil }
    var answeredRight: Bool { picked == question.answer }

    /// What a button or the prompt shows for a number in this mode.
    func label(for number: Int, inChinese: Bool) -> String {
        inChinese ? ChineseNumerals.literal(for: number) : "\(number)"
    }

    func pick(_ choice: Int) {
        guard picked == nil else { return }
        picked = choice
        answeredCount += 1
        if choice == question.answer {
            correctCount += 1
            streak += 1
            if streak > bestStreak {
                bestStreak = streak
                defaults.set(bestStreak, forKey: Self.bestStreakKey)
            }
        } else {
            streak = 0
        }
        // Say the right answer either way, so each tap is also a listening moment.
        say()
    }

    func next() {
        question = NumberQuiz.question(in: range.numbers, avoiding: question.answer, using: &generator)
        picked = nil
        if mode == .listen { say() }
    }

    /// Says the current answer aloud in Chinese.
    func say() {
        SpeechSynthesizerManager.shared.speak(
            ChineseNumerals.literal(for: question.answer),
            language: voice.language,
            rate: 0.4
        )
    }

    func stop() {
        SpeechSynthesizerManager.shared.stopSpeaking()
    }

    private func restart() {
        streak = 0
        correctCount = 0
        answeredCount = 0
        next()
    }
}
