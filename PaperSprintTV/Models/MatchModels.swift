import Foundation

struct MatchSettings: Equatable {
    var subjectID = "all"
    var playerCount = 2
    var rounds = 2

    var subjectName: String {
        LearningCatalog.subjects.first { $0.id == subjectID }?.name ?? "Mixed subjects"
    }
    var pool: [Question] {
        if subjectID == "all" { return LearningCatalog.questions }
        let lessonIDs = Set(LearningCatalog.lessons.filter { $0.subjectID == subjectID }.map(\.id))
        return LearningCatalog.questions.filter { lessonIDs.contains($0.lessonID) }
    }
    var availableRounds: [Int] {
        [2, 3, 5].filter { $0 * playerCount <= pool.count }
    }
    mutating func normalise() {
        if subjectID != "all" && !LearningCatalog.subjects.contains(where: { $0.id == subjectID }) {
            subjectID = "all"
        }
        playerCount = min(max(playerCount, 2), 4)
        if !availableRounds.contains(rounds) { rounds = availableRounds.first ?? 2 }
    }
}

struct TeamScore: Identifiable, Equatable {
    let id: Int
    let name: String
    var answered = 0
    var correct = 0
    var points: Int { correct * 100 }
    var accuracy: Double { QuizRules.percentage(correct: correct, total: answered) }
}

enum MatchPhase: String, Equatable {
    case handoff, answering, feedback, finished
}

enum MatchError: LocalizedError {
    case invalidSettings
    case insufficientQuestions
    var errorDescription: String? {
        switch self {
        case .invalidSettings: return "Choose 2–4 teams and a supported number of rounds."
        case .insufficientQuestions: return "There are not enough unique questions for this match. Choose fewer rounds or Mixed subjects."
        }
    }
}
