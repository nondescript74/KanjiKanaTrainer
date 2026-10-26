//
//  CharacterGlyph+Audio.swift
//  KanjiKanaTrainer
//
//  Created by Assistant on 12/19/25.
//

import AVFoundation
import Foundation
import Combine

/// Extension to add audio pronunciation capabilities to CharacterGlyph.
///
/// Speech voices read characters, not romanisation: a Mandarin voice given the
/// pinyin "yī" may spell it out or misread it, but given 一 it says yī. So every
/// method here speaks the character itself, in the right voice, through one
/// shared synthesizer (a local AVSpeechSynthesizer is released when the method
/// returns and can cut the speech off).
extension CharacterGlyph {

    /// Voice language for this glyph's script.
    var speechLanguage: String {
        switch script {
        case .kana, .kanji: return "ja-JP"
        case .hanzi: return "zh-CN"
        }
    }

    /// Play the pronunciation of this character (Mandarin for hanzi, Japanese for kana/kanji).
    /// - Parameters:
    ///   - language: Voice language; defaults to the script's language.
    ///   - rate: Speech rate (default 0.4, a learner-friendly pace).
    @MainActor
    func playPronunciation(language: String? = nil, rate: Float = 0.4) {
        SpeechSynthesizerManager.shared.speak(literal, language: language ?? speechLanguage, rate: rate)
    }

    /// Play the Cantonese pronunciation of a Chinese character (Hong Kong voice).
    @MainActor
    func playCantonesePronunciation(rate: Float = 0.4) {
        guard script == .hanzi else { return }
        SpeechSynthesizerManager.shared.speak(literal, language: "zh-HK", rate: rate)
    }

    @available(*, deprecated, renamed: "playCantonesePronunciation(rate:)")
    @MainActor
    func playCantonesePromunication(rate: Float = 0.4) {
        playCantonesePronunciation(rate: rate)
    }

    /// Play pronunciation with the literal character.
    @MainActor
    func playLiteralPronunciation(rate: Float = 0.5) {
        playPronunciation(rate: rate)
    }

    /// The romanised reading to show on screen (pinyin for hanzi, romaji for kana); not for speech.
    var displayReading: String? { readings.first }
}

/// Shared speech synthesizer for stopping playback
@MainActor
class SpeechSynthesizerManager: ObservableObject {
    static let shared = SpeechSynthesizerManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {}

    /// Speak text in a given voice language, interrupting anything already playing.
    func speak(_ text: String, language: String, rate: Float) {
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.preUtteranceDelay = 0.1
        #if DEBUG
        print("🔊 Speaking '\(text)' (\(language))")
        #endif
        synthesizer.speak(utterance)
    }
    
    /// Stop any currently playing speech
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// Check if speech is currently active
    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
