import SwiftUI

struct ScoreboardView: View {
    let session: TVQuizSession
    let onReplay: () -> Void
    let onSetup: () -> Void
    let onHome: () -> Void
    @FocusState private var replayFocused: Bool

    private var winnerNames: String { session.winners.map(\.name).joined(separator: " & ") }
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            TVHeader(title: "Final Scoreboard", subtitle: "\(session.settings.subjectName) · \(session.settings.rounds) rounds completed")
            HStack(spacing: 24) {
                Image(systemName: "trophy.fill").font(.system(size: 73)).foregroundStyle(Color.yellow)
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.winners.count == 1 ? "\(winnerNames) wins!" : "It's a tie!")
                        .font(.system(size: 59, weight: .bold, design: .rounded))
                        .accessibilityIdentifier("winnerTitle")
                    Text(session.winners.count == 1 ? "Great teamwork. Keep learning together." : "Joint winners: \(winnerNames)")
                        .font(.system(size: 27)).foregroundStyle(TVTheme.muted)
                }
            }
            .padding(.vertical, 12)
            VStack(spacing: 12) {
                ForEach(session.rankedTeams) { team in
                    HStack(spacing: 25) {
                        Image(systemName: session.winners.contains(where: { $0.id == team.id }) ? "crown.fill" : "person.2.fill")
                            .foregroundStyle(TVTheme.teamColor(team.id)).frame(width: 45)
                        Text(team.name).font(.system(size: 32, weight: .semibold))
                        Spacer()
                        Text("\(team.correct)/\(team.answered) correct")
                            .font(.system(size: 26)).foregroundStyle(TVTheme.muted)
                        Text("\(Int(team.accuracy))%")
                            .font(.system(size: 29, weight: .semibold)).frame(width: 110)
                        Text("\(team.points) pts")
                            .font(.system(size: 34, weight: .bold, design: .rounded)).frame(width: 175, alignment: .trailing)
                    }
                    .padding(.horizontal, 28).padding(.vertical, 16)
                    .background(TVTheme.panel, in: RoundedRectangle(cornerRadius: 20))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("scoreTeam\(team.id)")
                }
            }
            HStack(spacing: 25) {
                Button(action: onReplay) { TVActionLabel(title: "Play again", icon: "arrow.clockwise") }
                    .buttonStyle(TVFocusStyle(prominent: true)).focused($replayFocused)
                    .accessibilityIdentifier("playAgain")
                Button(action: onSetup) { TVActionLabel(title: "Change match", icon: "slider.horizontal.3") }
                    .buttonStyle(TVFocusStyle()).accessibilityIdentifier("changeMatch")
                Button(action: onHome) { TVActionLabel(title: "Home", icon: "house.fill") }
                    .buttonStyle(TVFocusStyle()).accessibilityIdentifier("scoreHome")
            }
            .padding(.top, 10)
            Text("Match scores are shown for this session. Play again starts a new shuffled match with zero scores.")
                .font(.system(size: 22)).foregroundStyle(TVTheme.muted)
        }
        .frame(maxWidth: 1640, maxHeight: .infinity, alignment: .topLeading).padding(48)
        .task { replayFocused = true }
    }
}
