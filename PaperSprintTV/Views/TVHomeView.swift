import SwiftUI

struct TVHomeView: View {
    let start: () -> Void
    let instructions: () -> Void
    @FocusState private var startFocused: Bool

    var body: some View {
        ZStack {
            TVBackground()
            VStack(alignment: .leading, spacing: 32) {
                Label("PAPERSPRINT TV", systemImage: "bolt.fill")
                    .font(.system(size: 30, weight: .bold)).foregroundStyle(TVTheme.mint)
                Text("Big screen.\nShared knowledge.")
                    .font(.system(size: 88, weight: .bold, design: .rounded))
                    .accessibilityIdentifier("homeTitle")
                Text("Turn revision into a team challenge.\nChoose a subject, pass the remote and make every answer count.")
                    .font(.system(size: 31)).foregroundStyle(TVTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 40) {
                    feature("2–4 teams", "person.2.fill")
                    feature("One shared remote", "appletvremote.gen4.fill")
                    feature("30 local questions", "text.book.closed.fill")
                }
                .padding(.vertical, 12)
                HStack(spacing: 30) {
                    Button(action: start) {
                        TVActionLabel(title: "Start a match", icon: "play.fill")
                    }
                    .buttonStyle(TVFocusStyle(prominent: true))
                    .focused($startFocused)
                    .accessibilityIdentifier("startMatch")
                    Button(action: instructions) {
                        TVActionLabel(title: "How to play", icon: "questionmark.circle")
                    }
                    .buttonStyle(TVFocusStyle())
                    .accessibilityIdentifier("howToPlay")
                }
                Text("Same PaperSprint topics. A new way to learn together.")
                    .font(.system(size: 23)).foregroundStyle(TVTheme.muted)
            }
            .frame(maxWidth: 1450, alignment: .leading)
            .padding(65)
        }
        .task { startFocused = true }
    }

    private func feature(_ text: String, _ icon: String) -> some View {
        Label(text, systemImage: icon).font(.system(size: 25, weight: .medium))
    }
}

struct InstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var backFocused: Bool
    private let instructions: [(String, String)] = [
        ("Make your teams", "Choose 2–4 players or teams, a subject and a match length. Each team answers once per round."),
        ("Pass the remote", "The handover screen names the next team. Select Ready to reveal that team's question."),
        ("Choose and check", "Move with the directional controls. Press Select on an answer, then choose Check answer to lock it in."),
        ("Learn from feedback", "A correct answer earns 100 points. A wrong answer earns 0. Read the explanation, then continue. No speed bonus."),
        ("See the result", "The scoreboard shows points and accuracy. Equal top scores share the win. Play again for a shuffled match.")
    ]
    var body: some View {
        ZStack {
            TVBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TVHeader(title: "How to play", subtitle: "A turn-based challenge for one room and one remote.")
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 24) {
                            Text("\(index + 1)").font(.system(size: 32, weight: .bold)).foregroundStyle(TVTheme.mint)
                                .frame(width: 46)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(instructions[index].0).font(.system(size: 26, weight: .semibold))
                                Text(instructions[index].1).font(.system(size: 23)).foregroundStyle(TVTheme.muted)
                            }
                        }
                    }
                    Text("Original practice questions, shared with the iOS app. Not official examination material. No sign-in or internet connection is required.")
                        .font(.system(size: 23)).foregroundStyle(TVTheme.muted)
                    Button { dismiss() } label: { TVActionLabel(title: "Back to Home", icon: "arrow.left") }
                        .buttonStyle(TVFocusStyle(prominent: true)).focused($backFocused)
                        .frame(width: 420).accessibilityIdentifier("instructionsBack")
                }
                .frame(maxWidth: 1600, alignment: .leading).padding(48)
            }
        }
        .task { backFocused = true }
    }
}
