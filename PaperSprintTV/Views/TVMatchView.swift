import SwiftUI

struct TVMatchView: View {
    @State var session: TVQuizSession
    let onSetup: () -> Void
    let onHome: () -> Void
    @State private var confirmExit = false
    @State private var replayError: String?
    @FocusState private var focus: ArenaFocus?

    private enum ArenaFocus: Hashable {
        case ready, answer(Int), check, next, quit
    }

    var body: some View {
        ZStack {
            TVBackground()
            if session.phase == .finished {
                ScoreboardView(session: session, onReplay: replay, onSetup: onSetup, onHome: onHome)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    TVHeader(title: session.phase == .handoff ? "Pass the remote" : "Quiz Arena",
                             subtitle: "\(session.settings.subjectName) · Round \(session.round) of \(session.settings.rounds)")
                    HStack(spacing: 18) {
                        ForEach(session.teams) { team in
                            TeamTile(team: team, active: team.id == session.activeTeamIndex)
                        }
                    }
                    ProgressView(value: session.progress).tint(TVTheme.mint)
                        .accessibilityLabel("Match progress")
                    if session.phase == .handoff {
                        handoff
                    } else {
                        questionContent
                    }
                }
                .frame(maxWidth: 1640, maxHeight: .infinity, alignment: .topLeading)
                .padding(48)
            }
        }
        .onExitCommand {
            if session.phase == .finished { onSetup() } else { confirmExit = true }
        }
        .alert("Leave this match?", isPresented: $confirmExit) {
            Button("Keep playing", role: .cancel) {}
            Button("Leave match", role: .destructive, action: onHome)
        } message: {
            Text("This unfinished match will end. Its scores are not saved.")
        }
        .alert("Unable to restart", isPresented: Binding(
            get: { replayError != nil }, set: { if !$0 { replayError = nil } }
        )) {
            Button("OK", role: .cancel) { replayError = nil }
        } message: { Text(replayError ?? "") }
        .task(id: session.phase) {
            switch session.phase {
            case .handoff: focus = .ready
            case .answering: focus = .answer(0)
            case .feedback: focus = .next
            case .finished: focus = nil
            }
        }
        .onChange(of: confirmExit) { _, showing in
            if !showing { restoreFocus() }
        }
    }

    private var handoff: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)
            Image(systemName: "appletvremote.gen4.fill")
                .font(.system(size: 68)).foregroundStyle(TVTheme.teamColor(session.activeTeamIndex))
            Text("\(session.activeTeam.name), you're up.")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .accessibilityIdentifier("handoffTitle")
            Text("Pass the remote to \(session.activeTeam.name).\nSelect Ready when your team is ready to answer.")
                .font(.system(size: 29)).foregroundStyle(TVTheme.muted).multilineTextAlignment(.center)
            Button { session.beginTurn() } label: {
                TVActionLabel(title: "Ready to play", icon: "play.fill")
            }
            .buttonStyle(TVFocusStyle(prominent: true))
            .focused($focus, equals: .ready).frame(width: 500)
            .accessibilityIdentifier("readyToPlay")
            Spacer(minLength: 8)
            Text("Question \(session.turnIndex + 1) of \(session.questions.count) · No timer. Think it through together.")
                .font(.system(size: 24)).foregroundStyle(TVTheme.muted)
            leaveButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var questionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(session.activeTeam.name.uppercased()) · QUESTION \(session.turnIndex + 1)")
                    .foregroundStyle(TVTheme.teamColor(session.activeTeamIndex))
                Spacer()
                Text("100 points available").foregroundStyle(TVTheme.muted)
            }
            .font(.system(size: 23, weight: .semibold))
            Text(session.currentQuestion.questionText)
                .font(.system(size: 38, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
                .accessibilityIdentifier("questionText")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
                ForEach(session.currentQuestion.options.indices, id: \.self) { index in
                    if session.phase == .answering {
                        Button { session.select(index) } label: { answerLabel(index) }
                            .buttonStyle(TVFocusStyle(selected: session.selectedIndex == index))
                            .focused($focus, equals: .answer(index))
                            .accessibilityIdentifier("answer\(index)")
                            .accessibilityValue(session.selectedIndex == index ? "Selected" : "Not selected")
                    } else {
                        answerLabel(index)
                            .padding(.horizontal, 26).padding(.vertical, 18)
                            .background(TVTheme.panel, in: RoundedRectangle(cornerRadius: 20))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20).strokeBorder(answerColor(index), lineWidth: 3)
                            }
                            .accessibilityElement(children: .combine)
                    }
                }
            }
            if session.phase == .feedback {
                feedback
                Button { session.advance() } label: {
                    TVActionLabel(title: session.isLastTurn ? "See scoreboard" : "Next team", icon: "arrow.right")
                }
                .buttonStyle(TVFocusStyle(prominent: true)).focused($focus, equals: .next)
                .frame(width: 500).accessibilityIdentifier("nextTeam")
            } else {
                Button { session.checkAnswer() } label: {
                    HStack {
                        Label("Check answer", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 29, weight: .semibold))
                        Spacer()
                        Text(session.selectedIndex == nil ? "Select an answer first" : "Select to lock in your answer")
                            .font(.system(size: 23))
                    }
                    .frame(maxWidth: .infinity, minHeight: 34)
                }
                .buttonStyle(TVFocusStyle(prominent: true))
                .disabled(session.selectedIndex == nil)
                .focused($focus, equals: .check)
                .accessibilityIdentifier("checkAnswer")
                Text("Directional controls move focus · Select chooses · Back/Menu opens the leave-match prompt")
                    .font(.system(size: 22)).foregroundStyle(TVTheme.muted)
            }
        }
    }

    private func answerLabel(_ index: Int) -> some View {
        HStack(alignment: .center, spacing: 18) {
            Text(index < 4 ? ["A", "B", "C", "D"][index] : String(index + 1))
                .font(.system(size: 27, weight: .bold)).frame(width: 38)
            Text(session.currentQuestion.options[index])
                .font(.system(size: 27, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if session.phase == .feedback {
                if index == session.currentQuestion.correctAnswerIndex {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(TVTheme.mint)
                        .accessibilityLabel("Correct answer")
                } else if index == session.selectedIndex {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Color.red)
                        .accessibilityLabel("Your answer, incorrect")
                }
            } else if session.selectedIndex == index {
                Image(systemName: "checkmark.circle.fill").accessibilityLabel("Selected")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
    }
    private func answerColor(_ index: Int) -> Color {
        if index == session.currentQuestion.correctAnswerIndex { return TVTheme.mint }
        if index == session.selectedIndex { return .red }
        return Color.white.opacity(0.12)
    }
    private var feedback: some View {
        HStack(alignment: .top, spacing: 18) {
            Image(systemName: session.answerWasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(session.answerWasCorrect ? TVTheme.mint : Color.orange)
                .font(.system(size: 35))
            VStack(alignment: .leading, spacing: 7) {
                Text(session.answerWasCorrect ? "Correct! +100 points" : "Not quite. +0 points")
                    .font(.system(size: 28, weight: .bold)).accessibilityIdentifier("answerFeedback")
                Text(session.currentQuestion.explanation)
                    .font(.system(size: 23)).foregroundStyle(TVTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
    }
    private var leaveButton: some View {
        Button { confirmExit = true } label: {
            Label("Leave match", systemImage: "xmark").font(.system(size: 23))
        }
        .buttonStyle(TVFocusStyle()).focused($focus, equals: .quit)
        .accessibilityIdentifier("leaveMatch")
    }
    private func restoreFocus() {
        switch session.phase {
        case .handoff: focus = .ready
        case .answering: focus = .answer(session.selectedIndex ?? 0)
        case .feedback: focus = .next
        case .finished: break
        }
    }
    private func replay() {
        do {
            session = try TVQuizSession(settings: session.settings,
                shuffle: !ProcessInfo.processInfo.arguments.contains("--uitesting"))
        } catch { replayError = error.localizedDescription }
    }
}
