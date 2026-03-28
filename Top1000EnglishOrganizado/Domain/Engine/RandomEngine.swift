import Foundation

struct RandomEngine {
    static func buildSession(
        mode: PracticeMode,
        repo: ContentRepository,
        reviewPool: [ReviewItem],
        count: Int = 10
    ) -> [Question] {

        let reviewCount = min(Int(Double(count) * 0.30), reviewPool.count)
        let newCount = count - reviewCount

        var questions: [Question] = []

        // 30% revisão
        if reviewCount > 0 {
            let picks = Array(reviewPool.shuffled().prefix(reviewCount))
            for item in picks {
                questions.append(
                    Question(
                        id: "r-\(item.key)",
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
        return Array(questions.prefix(count))
    }

    private static func makeWordQuestions(_ words: [WordItem], repo: ContentRepository, limit: Int) -> [Question] {
        var result: [Question] = []
        let picks = Array(words.shuffled().prefix(limit))

        for w in picks {
            let prompt = "Qual a tradução de “\(w.en)” ?"
            let correct = w.pt

            var options = [correct]
            let distractors = repo.words
                .filter { $0.id != w.id }
                .map { $0.pt }
                .shuffled()
                .prefix(3)

            options.append(contentsOf: distractors)
            options = options.shuffled()

            let correctIndex = options.firstIndex(of: correct) ?? 0
            let explanation = "Exemplo: “\(w.example)”"

            result.append(
                Question(
                    id: "w-\(w.id)",
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

    private static func makePhraseQuestions(_ phrases: [PhraseItem], repo: ContentRepository, limit: Int) -> [Question] {
        var result: [Question] = []
        let picks = Array(phrases.shuffled().prefix(limit))

        for p in picks {
            let prompt = "Qual a tradução da frase?\n“\(p.en)”"
            let correct = p.pt

            var options = [correct]
            let distractors = repo.phrases
                .filter { $0.id != p.id }
                .map { $0.pt }
                .shuffled()
                .prefix(3)

            options.append(contentsOf: distractors)
            options = options.shuffled()

            let correctIndex = options.firstIndex(of: correct) ?? 0
            let explanation = "Tag: \(p.tags.first ?? "daily")"

            result.append(
                Question(
                    id: "p-\(p.id)",
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

    private static func makeScenarioQuestions(repo: ContentRepository, limit: Int) -> [Question] {
        var result: [Question] = []
        let scenario = repo.scenarios.randomElement() ?? repo.scenarios[0]

        let relatedPhrases = repo.phrases.filter { !$0.tags.isEmpty && $0.tags.contains(where: scenario.tags.contains) }
        let relatedWords = repo.words.filter { !$0.tags.isEmpty && $0.tags.contains(where: scenario.tags.contains) }

        let phrasePool = (relatedPhrases.isEmpty ? repo.phrases : relatedPhrases)
        let wordPool = (relatedWords.isEmpty ? repo.words : relatedWords)

        let half = max(1, limit / 2)
        result.append(contentsOf: makePhraseQuestions(Array(phrasePool.shuffled().prefix(half)), repo: repo, limit: half))
        result.append(contentsOf: makeWordQuestions(Array(wordPool.shuffled().prefix(limit - half)), repo: repo, limit: (limit - half)))

        result = result.map { q in
            Question(
                id: q.id + "-s:\(scenario.id)",
                type: q.type,
                prompt: "Cenário: \(scenario.name)\n\n" + q.prompt,
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
                return pool.words.map { $0.pt }.filter { $0 != correct }.shuffled()
            case .phrases, .scenario:
                return pool.phrases.map { $0.pt }.filter { $0 != correct }.shuffled()
            }
        }()

        options.append(contentsOf: distractors.prefix(3))
        return options.shuffled()
    }

    private static func shuffleAvoidingSamePrompt(_ input: [Question]) -> [Question] {
        var arr = input.shuffled()
        for i in 1..<arr.count {
            if arr[i].prompt == arr[i-1].prompt {
                arr.swapAt(i, max(0, i-1))
            }
        }
        return arr
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
