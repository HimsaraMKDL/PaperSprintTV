import SwiftUI

struct ContentView: View {
    @State private var path: [TVRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            TVHomeView(start: { path.append(.setup) }, instructions: { path.append(.instructions) })
                .navigationDestination(for: TVRoute.self) { route in
                    switch route {
                    case .setup: MatchSetupView { path.removeAll() }
                    case .instructions: InstructionsView()
                    }
                }
        }
        .tint(TVTheme.mint)
    }
}

private enum TVRoute: Hashable {
    case setup, instructions
}

#Preview { ContentView() }
