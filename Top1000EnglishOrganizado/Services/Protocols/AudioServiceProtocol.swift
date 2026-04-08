import Foundation

/// Abstração de áudio — hoje usa AVSpeechSynthesizer, futuramente pode usar API de TTS
protocol AudioServiceProtocol {
    func speak(_ text: String, language: String)
    func stop()
}
