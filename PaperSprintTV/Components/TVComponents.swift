import SwiftUI

enum TVTheme {
    static let background = Color(red: 0.035, green: 0.05, blue: 0.12)
    static let panel = Color(red: 0.08, green: 0.10, blue: 0.19)
    static let accent = Color(red: 0.57, green: 0.62, blue: 1)
    static let mint = Color(red: 0.32, green: 0.90, blue: 0.75)
    static let muted = Color(red: 0.70, green: 0.74, blue: 0.85)
    static func teamColor(_ index: Int) -> Color {
        [accent, mint, Color.orange, Color.pink][index % 4]
    }
}

struct TVBackground: View {
    var body: some View {
        LinearGradient(colors: [TVTheme.background, Color(red: 0.08, green: 0.08, blue: 0.20)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct TVFocusStyle: ButtonStyle {
    var selected = false
    var prominent = false
    func makeBody(configuration: Configuration) -> some View {
        TVFocusBody(content: configuration.label, pressed: configuration.isPressed,
                    selected: selected, prominent: prominent)
    }
}

private struct TVFocusBody<Content: View>: View {
    let content: Content
    let pressed: Bool
    let selected: Bool
    let prominent: Bool
    @Environment(\.isFocused) private var focused
    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content
            .padding(.horizontal, 26)
            .padding(.vertical, 18)
            .foregroundStyle(focused || prominent ? TVTheme.background : Color.white)
            .background(background, in: RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(focused ? Color.white : (selected ? TVTheme.mint : Color.white.opacity(0.15)),
                                  lineWidth: focused ? 5 : (selected ? 3 : 1))
            }
            .scaleEffect(reduceMotion ? 1 : (pressed ? 0.98 : (focused ? 1.025 : 1)))
            .shadow(color: focused ? TVTheme.accent.opacity(0.3) : .clear, radius: 18)
            .opacity(enabled ? 1 : 0.4)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: focused)
    }
    private var background: Color {
        if focused { return TVTheme.mint }
        if prominent { return TVTheme.accent }
        return selected ? Color(red: 0.12, green: 0.25, blue: 0.27) : TVTheme.panel
    }
}

struct TVActionLabel: View {
    let title: String
    let icon: String
    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 29, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 34)
    }
}

struct TVHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 9) {
                Text(title).font(.system(size: 42, weight: .bold))
                Text(subtitle).font(.system(size: 25)).foregroundStyle(TVTheme.muted)
            }
            Spacer(minLength: 20)
            Label("PAPERSPRINT TV", systemImage: "bolt.fill")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(TVTheme.mint)
                .padding(.top, 12)
        }
    }
}

struct TeamTile: View {
    let team: TeamScore
    var active = false
    var body: some View {
        HStack(spacing: 15) {
            Circle().fill(TVTheme.teamColor(team.id)).frame(width: 13, height: 13)
            Text(team.name).font(.system(size: 25, weight: .semibold))
            Spacer(minLength: 12)
            Text("\(team.points)").font(.system(size: 29, weight: .bold, design: .rounded))
        }
        .padding(16)
        .background(TVTheme.panel, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(active ? TVTheme.teamColor(team.id) : Color.white.opacity(0.08), lineWidth: active ? 3 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(team.name), \(team.points) points\(active ? ", current turn" : "")")
    }
}
