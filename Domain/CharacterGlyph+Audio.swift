//
//  CharacterGlyph+Audio.swift
//  KanjiKanaTrainer
//
//  Created by Assistant on 12/19/25.
//

import AVFoundation
import Foundation
import Combine

/// Extension to add audio pronunciation capabilities to CharacterGlyph
extension CharacterGlyph {
    
    /// Play the pronunciation of this character using iOS text-to-speech
    /// - Parameters:
    ///   - language: Language code (default: "zh-CN" for Mandarin Chinese)
    ///   - rate: Speech rate (default: 0.4 for learner-friendly pace)
    @MainActor
    func playPronunciation(language: String? = nil, rate: Float = 0.4) {
        guard !readings.isEmpty else {
            #if DEBUG
            print("⚠️ No pronunciation available for '\(literal)'")
            #endif
            return
        }
        
        let synthesizer = AVSpeechSynthesizer()
        
        // Determine language based on script if not provided
        let languageCode: String
        if let language = language {
            languageCode = language
        } else {
            switch script {
            case .kana, .kanji:
                languageCode = "ja-JP" // Japanese
            case .hanzi:
                languageCode = "zh-CN" // Mandarin Chinese
            }
        }
        
        // Use the first reading (Mandarin pinyin for Chinese, romaji for Japanese)
        let pronunciation = readings[0]
        let utterance = AVSpeechUtterance(string: pronunciation)
        
        // Configure voice
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        // Slow down for learners
        utterance.rate = rate
        
        // Optional: adjust pitch slightly for clarity
        utterance.pitchMultiplier = 1.0
        
        // Add a slight pause before speaking
        utterance.preUtteranceDelay = 0.1
        
        #if DEBUG
        print("🔊 Playing pronunciation: '\(pronunciation)' for character '\(literal)' (language: \(languageCode))")
        #endif
        
        synthesizer.speak(utterance)
    }
    
    /// Play the Cantonese pronunciation (uses second reading if available)
    @MainActor
    func playCantonesePromunication(rate: Float = 0.4) {
        guard readings.count >= 2 else {
            #if DEBUG
            print("⚠️ No Cantonese pronunciation available for '\(literal)'")
            #endif
            return
        }
        
        let synthesizer = AVSpeechSynthesizer()
        let jyutping = readings[1] // Second reading is Cantonese jyutping
        let utterance = AVSpeechUtterance(string: jyutping)
        
        // Use Hong Kong Cantonese voice
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-HK")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1
        
        #if DEBUG
        print("🔊 Playing Cantonese: '\(jyutping)' for character '\(literal)'")
        #endif
        
        synthesizer.speak(utterance)
    }
    
    /// Play pronunciation with the literal character (useful for Chinese)
    @MainActor
    func playLiteralPronunciation(rate: Float = 0.5) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: literal)
        
        let languageCode: String
        switch script {
        case .kana, .kanji:
            languageCode = "ja-JP"
        case .hanzi:
            languageCode = "zh-CN"
        }
        
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        
        #if DEBUG
        print("🔊 Playing literal: '\(literal)' (language: \(languageCode))")
        #endif
        
        synthesizer.speak(utterance)
    }
}

/// Shared speech synthesizer for stopping playback
@MainActor
class SpeechSynthesizerManager: ObservableObject {
    static let shared = SpeechSynthesizerManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {}
    
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
