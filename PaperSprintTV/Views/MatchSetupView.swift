import SwiftUI

struct MatchSetupView: View {
    let onHome: () -> Void

    @State private var settings = MatchSettings()
    @State private var activeSession: TVQuizSession?
    @State private var errorMessage: String?

    @FocusState private var startFocused: Bool

    var body: some View {
        Group {
            if let activeSession {
                TVMatchView(
                    session: activeSession,
                    onSetup: {
                        self.activeSession = nil
                    },
                    onHome: {
                        self.activeSession = nil
                        onHome()
                    }
                )
            } else {
                setupScreen
            }
        }
        .alert(
            "Unable to start match",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { newValue in
                    if !newValue {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var setupScreen: some View {
        ZStack {
            TVBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    TVHeader(
                        title: "Build your match",
                        subtitle: "Choose your topic. Gather your teams. Share one remote."
                    )

                    // MARK: - SUBJECT

                    sectionTitle("01", "Choose a subject")

                    HStack(spacing: 22) {

                        subjectButton(
                            id: "all",
                            name: "Mixed subjects",
                            subtitle: "All 30 questions",
                            icon: "square.grid.2x2.fill"
                        )

                        ForEach(LearningCatalog.subjects) { subject in
                            subjectButton(
                                id: subject.id,
                                name: subject.name,
                                subtitle: "10 questions",
                                icon: subject.icon
                            )
                        }
                    }

                    // MARK: - TEAMS

                    sectionTitle("02", "Players or teams")

                    HStack(spacing: 22) {
                        ForEach(2...4, id: \.self) { count in

                            Button {
                                settings.playerCount = count
                                settings.normalise()
                            } label: {
                                choiceLabel(
                                    "\(count) teams",
                                    selected: settings.playerCount == count
                                )
                            }
                            .buttonStyle(
                                TVFocusStyle(
                                    selected: settings.playerCount == count
                                )
                            )
                            .accessibilityIdentifier("teams\(count)")
                            .accessibilityValue(
                                settings.playerCount == count
                                ? "Selected"
                                : "Not selected"
                            )
                        }
                    }

                    // MARK: - ROUNDS

                    sectionTitle("03", "Questions per team")

                    HStack(spacing: 22) {
                        ForEach([2, 3, 5], id: \.self) { rounds in

                            Button {
                                settings.rounds = rounds
                            } label: {
                                choiceLabel(
                                    "\(rounds) rounds",
                                    selected: settings.rounds == rounds
                                )
                            }
                            .buttonStyle(
                                TVFocusStyle(
                                    selected: settings.rounds == rounds
                                )
                            )
                            .disabled(
                                !settings.availableRounds.contains(rounds)
                            )
                            .accessibilityIdentifier("rounds\(rounds)")
                            .accessibilityValue(
                                settings.rounds == rounds
                                ? "Selected"
                                : "Not selected"
                            )
                        }
                    }

                    // MARK: - SUMMARY

                    Text(
                        "\(settings.playerCount) teams · " +
                        "\(settings.rounds) questions each · " +
                        "\(settings.playerCount * settings.rounds) unique questions · " +
                        "100 points per correct answer"
                    )
                    .font(.system(size: 25))
                    .foregroundStyle(TVTheme.muted)
                    .accessibilityIdentifier("matchSummary")

                    // MARK: - BUTTONS

                    HStack(spacing: 25) {

                        Button {
                            beginMatch()
                        } label: {
                            TVActionLabel(
                                title: "Begin match",
                                icon: "play.fill"
                            )
                        }
                        .buttonStyle(
                            TVFocusStyle(prominent: true)
                        )
                        .focused($startFocused)
                        .accessibilityIdentifier("beginMatch")

                        Button {
                            onHome()
                        } label: {
                            TVActionLabel(
                                title: "Back to Home",
                                icon: "arrow.left"
                            )
                        }
                        .buttonStyle(TVFocusStyle())
                        .accessibilityIdentifier("setupHome")
                    }
                }
                .frame(
                    maxWidth: 1640,
                    alignment: .leading
                )
                .padding(60)
            }
        }
        .task {
            startFocused = true
        }
    }

    // MARK: - START MATCH

    private func beginMatch() {

        settings.normalise()

        do {
            let newSession = try TVQuizSession(
                settings: settings,
                shuffle: !ProcessInfo.processInfo.arguments.contains("--uitesting")
            )

            activeSession = newSession

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - SECTION TITLE

    private func sectionTitle(
        _ number: String,
        _ title: String
    ) -> some View {

        HStack(spacing: 16) {

            Text(number)
                .foregroundStyle(TVTheme.mint)

            Text(title)
        }
        .font(
            .system(
                size: 28,
                weight: .semibold
            )
        )
    }

    // MARK: - CHOICE LABEL

    private func choiceLabel(
        _ title: String,
        selected: Bool
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Image(
                systemName:
                    selected
                    ? "checkmark.circle.fill"
                    : "circle"
            )
        }
        .font(
            .system(
                size: 29,
                weight: .semibold
            )
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - SUBJECT BUTTON

    private func subjectButton(
        id: String,
        name: String,
        subtitle: String,
        icon: String
    ) -> some View {

        Button {

            settings.subjectID = id
            settings.normalise()

        } label: {

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                HStack {

                    Image(systemName: icon)

                    Spacer()

                    if settings.subjectID == id {
                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )
                    }
                }
                .font(
                    .system(
                        size: 28,
                        weight: .semibold
                    )
                )

                Text(name)
                    .font(
                        .system(
                            size: 28,
                            weight: .semibold
                        )
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .frame(
                        height: 72,
                        alignment: .leading
                    )

                Text(subtitle)
                    .font(.system(size: 23))
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .buttonStyle(
            TVFocusStyle(
                selected: settings.subjectID == id
            )
        )
        .accessibilityIdentifier("subject_\(id)")
        .accessibilityValue(
            settings.subjectID == id
            ? "Selected"
            : "Not selected"
        )
    }
}
