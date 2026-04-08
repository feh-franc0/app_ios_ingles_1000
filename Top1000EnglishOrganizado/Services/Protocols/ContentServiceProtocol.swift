import Foundation

/// Abstração de conteúdo — troque MockContentService por APIContentService no futuro
protocol ContentServiceProtocol {
    func fetchWords() async -> [WordItem]
    func fetchPhrases() async -> [PhraseItem]
    func fetchScenarios() async -> [ScenarioItem]
}
