import Foundation
import Observation

/// One shared remote, one question per team in each round. No timer or speed bonus.
@Observable
final class TVQuizSession {
    let settings: MatchSettings
    let questions: [Question]
    private(set) var teams: [TeamScore]
    private(set) var phase: MatchPhase = .handoff
    private(set) var turnIndex = 0
    private(set) var selectedIndex: Int?

    init(settings: MatchSettings, questions pool: [Question]? = nil, shuffle: Bool = true) throws {
        guard (2...4).contains(settings.playerCount), [2, 3, 5].contains(settings.rounds) else {
            throw MatchError.invalidSettings
        }
        var seen = Set<String>()
        let valid = (pool ?? settings.pool).filter { QuizRules.valid($0) && seen.insert($0.id).inserted }
        let required = settings.playerCount * settings.rounds
        guard valid.count >= required else { throw MatchError.insufficientQuestions }
        self.settings = settings
        questions = Array((shuffle ? valid.shuffled() : valid).prefix(required))
        teams = (0..<settings.playerCount).map { TeamScore(id: $0, name: "Team \($0 + 1)") }
    }

    var activeTeamIndex: Int { turnIndex % teams.count }
    var activeTeam: TeamScore { teams[activeTeamIndex] }
    var currentQuestion: Question { questions[turnIndex] }
    var round: Int { turnIndex / teams.count + 1 }
    var checkedCount: Int { teams.reduce(0) { $0 + $1.answered } }
    var progress: Double { Double(checkedCount) / Double(questions.count) }
    var isLastTurn: Bool { turnIndex == questions.count - 1 }
    var answerWasCorrect: Bool { selectedIndex == currentQuestion.correctAnswerIndex }
    var rankedTeams: [TeamScore] {
        teams.sorted { $0.points == $1.points ? $0.id < $1.id : $0.points > $1.points }
    }
    var winners: [TeamScore] {
        let best = teams.map(\.points).max() ?? 0
        return teams.filter { $0.points == best }
    }

    func beginTurn() {
        guard phase == .handoff else { return }
        phase = .answering
    }
    func select(_ index: Int) {
        guard phase == .answering, currentQuestion.options.indices.contains(index) else { return }
        selectedIndex = index
    }
    func checkAnswer() {
        guard phase == .answering, let selectedIndex else { return }
        teams[activeTeamIndex].answered += 1
        if selectedIndex == currentQuestion.correctAnswerIndex { teams[activeTeamIndex].correct += 1 }
        phase = .feedback
    }
    func advance() {
        guard phase == .feedback else { return }
        if isLastTurn {
            phase = .finished
        } else {
            turnIndex += 1
            selectedIndex = nil
            phase = .handoff
        }
    }
}
