import AVFoundation

/// Speaks characters with the built-in Mandarin voice. Works fully offline.
@MainActor
final class Speech {
    static let shared = Speech()
    private let synth = AVSpeechSynthesizer()

    func say(_ text: String, language: String = "zh-CN") {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: language)
        u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        synth.speak(u)
    }
}
