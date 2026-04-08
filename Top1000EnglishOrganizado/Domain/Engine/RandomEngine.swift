import Foundation

struct RandomEngine {

    // MARK: - Sessão só de revisão (100% do pool de erros)

    static func buildReviewOnlySession(
        reviewPool: [ReviewItem],
        repo: ContentRepository
    ) -> [Question] {
        guard !reviewPool.isEmpty else { return [] }

        return reviewPool.shuffled().map { item in
            let options = makeOptions(correct: item.correct, pool: repo, mode: .words)
            let shuffled = options.shuffled()
            let correctIndex = shuffled.firstIndex(of: item.correct) ?? 0

            return Question(
                id: "rev-\(item.key)-\(UUID().uuidString)",
                type: .multipleChoice,
                prompt: item.prompt,
                options: shuffled,
                correctIndex: correctIndex,
                explanation: item.hint,
                reviewKey: item.key
            )
        }
    }

    static func buildSession(
        mode: PracticeMode,
        repo: ContentRepository,
        reviewPool: [ReviewItem],
        count: Int = 10
    ) -> [Question] {
        let safeCount = max(1, count)

        let reviewCount = min(Int(Double(safeCount) * 0.30), reviewPool.count)
        let newCount = safeCount - reviewCount

        var questions: [Question] = []

        // 30% revisão
        if reviewCount > 0 {
            let picks = Array(reviewPool.shuffled().prefix(reviewCount))

            for item in picks {
                questions.append(
                    Question(
                        id: "r-\(item.key)-\(UUID().uuidString)",
                        type: .multipleChoice,
                        prompt: item.prompt,
                        options: makeOptions(correct: item.correct, pool: repo, mode: mode),
                        correctIndex: 0,
                        explanation: item.hint,
                        reviewKey: item.key
                    )
                    .normalizedCorrectFirst()
                )
            }
        }

        // 70% novos
        let newQs: [Question] = {
            switch mode {
            case .words:
                return makeWordQuestions(repo.words, repo: repo, limit: newCount)
            case .phrases:
                return makePhraseQuestions(repo.phrases, repo: repo, limit: newCount)
            case .scenario:
                return makeScenarioQuestions(repo: repo, limit: newCount)
            }
        }()

        questions.append(contentsOf: newQs)
        questions = shuffleAvoidingSamePrompt(questions)

        // Se ainda faltou pergunta, completa com mais questões do modo
        if questions.count < safeCount {
            let missing = safeCount - questions.count

            let extraQs: [Question] = {
                switch mode {
                case .words:
                    return makeWordQuestions(repo.words, repo: repo, limit: missing, allowRepeats: true)
                case .phrases:
                    return makePhraseQuestions(repo.phrases, repo: repo, limit: missing, allowRepeats: true)
                case .scenario:
                    return makeScenarioQuestions(repo: repo, limit: missing, allowRepeats: true)
                }
            }()

            questions.append(contentsOf: extraQs)
            questions = shuffleAvoidingSamePrompt(questions)
        }

        return Array(questions.prefix(safeCount))
    }

    private static func makeWordQuestions(
        _ words: [WordItem],
        repo: ContentRepository,
        limit: Int,
        allowRepeats: Bool = false
    ) -> [Question] {
        guard limit > 0, !words.isEmpty else { return [] }

        var result: [Question] = []
        let picks = pickWordItems(words, count: limit, allowRepeats: allowRepeats)

        for (idx, w) in picks.enumerated() {
            let prompt = "Qual a tradução de “\(w.en)”?"
            let correct = w.pt

            var options = [correct]

            let distractors = repo.words
                .filter { $0.id != w.id }
                .map { $0.pt }
                .shuffled()

            options.append(contentsOf: distractors.prefix(3))
            options = Array(Set(options)).shuffled()

            while options.count < 4 {
                if let extra = repo.words.map(\.pt).shuffled().first(where: { !options.contains($0) }) {
                    options.append(extra)
                } else {
                    break
                }
            }

            let correctIndex = options.firstIndex(of: correct) ?? 0
            let explanation = "Exemplo: “\(w.example)”"

            result.append(
                Question(
                    id: "w-\(w.id)-\(idx)-\(UUID().uuidString.prefix(6))",
                    type: .multipleChoice,
                    prompt: prompt,
                    options: options,
                    correctIndex: correctIndex,
                    explanation: explanation,
                    reviewKey: "w:\(w.en)"
                )
            )
        }

        return result
    }

    private static func makePhraseQuestions(
        _ phrases: [PhraseItem],
        repo: ContentRepository,
        limit: Int,
        allowRepeats: Bool = false
    ) -> [Question] {
        guard limit > 0, !phrases.isEmpty else { return [] }

        var result: [Question] = []
        let picks = pickPhraseItems(phrases, count: limit, allowRepeats: allowRepeats)

        for (idx, p) in picks.enumerated() {
            let prompt = "Qual a tradução da frase?\n“\(p.en)”"
            let correct = p.pt

            var options = [correct]

            let distractors = repo.phrases
                .filter { $0.id != p.id }
                .map { $0.pt }
                .shuffled()

            options.append(contentsOf: distractors.prefix(3))
            options = Array(Set(options)).shuffled()

            while options.count < 4 {
                if let extra = repo.phrases.map(\.pt).shuffled().first(where: { !options.contains($0) }) {
                    options.append(extra)
                } else {
                    break
                }
            }

            let correctIndex = options.firstIndex(of: correct) ?? 0
            let explanation = "Tag: \(p.tags.first ?? "daily")"

            result.append(
                Question(
                    id: "p-\(p.id)-\(idx)-\(UUID().uuidString.prefix(6))",
                    type: .multipleChoice,
                    prompt: prompt,
                    options: options,
                    correctIndex: correctIndex,
                    explanation: explanation,
                    reviewKey: "p:\(p.en)"
                )
            )
        }

        return result
    }

    private static func makeScenarioQuestions(
        repo: ContentRepository,
        limit: Int,
        allowRepeats: Bool = false
    ) -> [Question] {
        guard limit > 0 else { return [] }

        // Se não houver cenário cadastrado, cai para frases + palavras normais
        guard let scenario = repo.scenarios.randomElement() else {
            let half = max(1, limit / 2)
            let phraseQs = makePhraseQuestions(repo.phrases, repo: repo, limit: half, allowRepeats: allowRepeats)
            let wordQs = makeWordQuestions(repo.words, repo: repo, limit: limit - half, allowRepeats: allowRepeats)
            return shuffleAvoidingSamePrompt(phraseQs + wordQs)
        }

        let relatedPhrases = repo.phrases.filter {
            !$0.tags.isEmpty && $0.tags.contains(where: scenario.tags.contains)
        }

        let relatedWords = repo.words.filter {
            !$0.tags.isEmpty && $0.tags.contains(where: scenario.tags.contains)
        }

        let phrasePool = relatedPhrases.isEmpty ? repo.phrases : relatedPhrases
        let wordPool = relatedWords.isEmpty ? repo.words : relatedWords

        let half = max(1, limit / 2)

        var result: [Question] = []
        result.append(contentsOf: makePhraseQuestions(phrasePool, repo: repo, limit: half, allowRepeats: allowRepeats))
        result.append(contentsOf: makeWordQuestions(wordPool, repo: repo, limit: limit - half, allowRepeats: allowRepeats))

        result = result.enumerated().map { idx, q in
            Question(
                id: "\(q.id)-s-\(scenario.id)-\(idx)",
                type: q.type,
                prompt: "Cenário: \(scenario.name)\n\n\(q.prompt)",
                options: q.options,
                correctIndex: q.correctIndex,
                explanation: q.explanation,
                reviewKey: q.reviewKey
            )
        }

        return result
    }

    private static func makeOptions(correct: String, pool: ContentRepository, mode: PracticeMode) -> [String] {
        var options = [correct]

        let distractors: [String] = {
            switch mode {
            case .words:
                return pool.words.map(\.pt).filter { $0 != correct }.shuffled()
            case .phrases, .scenario:
                return pool.phrases.map(\.pt).filter { $0 != correct }.shuffled()
            }
        }()

        options.append(contentsOf: distractors.prefix(3))
        options = Array(Set(options)).shuffled()

        while options.count < 4 {
            let fallback: String? = {
                switch mode {
                case .words:
                    return pool.words.map(\.pt).shuffled().first(where: { !options.contains($0) })
                case .phrases, .scenario:
                    return pool.phrases.map(\.pt).shuffled().first(where: { !options.contains($0) })
                }
            }()

            guard let extra = fallback else { break }
            options.append(extra)
        }

        return options.shuffled()
    }

    private static func shuffleAvoidingSamePrompt(_ input: [Question]) -> [Question] {
        guard input.count > 1 else { return input }

        var arr = input.shuffled()

        for i in 1..<arr.count {
            if arr[i].prompt == arr[i - 1].prompt {
                let swapIndex = min(i + 1, arr.count - 1)
                if swapIndex != i {
                    arr.swapAt(i, swapIndex)
                }
            }
        }

        return arr
    }

    // MARK: - Pick helpers

    private static func pickWordItems(
        _ items: [WordItem],
        count: Int,
        allowRepeats: Bool
    ) -> [WordItem] {
        guard !items.isEmpty, count > 0 else { return [] }

        if !allowRepeats {
            return Array(items.shuffled().prefix(count))
        }

        var result: [WordItem] = []
        while result.count < count {
            result.append(contentsOf: items.shuffled())
        }
        return Array(result.prefix(count))
    }

    private static func pickPhraseItems(
        _ items: [PhraseItem],
        count: Int,
        allowRepeats: Bool
    ) -> [PhraseItem] {
        guard !items.isEmpty, count > 0 else { return [] }

        if !allowRepeats {
            return Array(items.shuffled().prefix(count))
        }

        var result: [PhraseItem] = []
        while result.count < count {
            result.append(contentsOf: items.shuffled())
        }
        return Array(result.prefix(count))
    }
}

private extension Question {
    func normalizedCorrectFirst() -> Question {
        let correct = options[correctIndex]
        var newOptions = options.filter { $0 != correct }
        newOptions.insert(correct, at: 0)

        return Question(
            id: id,
            type: type,
            prompt: prompt,
            options: newOptions,
            correctIndex: 0,
            explanation: explanation,
            reviewKey: reviewKey
        )
    }
}
