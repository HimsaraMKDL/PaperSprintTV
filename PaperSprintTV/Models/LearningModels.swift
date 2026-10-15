import Foundation

struct Subject: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
}
struct Lesson: Identifiable, Hashable, Codable {
    let id: String
    let subjectID: String
    let title: String
    let minutes: Int
    let introduction: String
    let sections: [LessonSection]
}
struct LessonSection: Hashable, Codable {
    let heading: String
    let body: String
}
struct Question: Identifiable, Hashable, Codable {
    let id: String
    let lessonID: String
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
}
struct AnswerRecord: Identifiable, Codable, Hashable {
    let id: String
    let questionText: String
    let options: [String]
    let selectedIndex: Int
    let correctIndex: Int
    let explanation: String
    var isCorrect: Bool { selectedIndex == correctIndex }
}

enum QuizRules {
    static func percentage(correct: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(min(max(correct, 0), total)) / Double(total) * 100
    }
    static func valid(_ question: Question) -> Bool {
        !question.questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && question.options.count >= 2
        && question.options.indices.contains(question.correctAnswerIndex)
        && question.options.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
