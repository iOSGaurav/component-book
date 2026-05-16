import SwiftUI

struct ButtonGallery: View {
    @State private var isLoadingDemo = false
    @State private var lastTapped: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if let lastTapped {
                    Text("Tapped: \(lastTapped)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }

                section("Styles") {
                    CBButton("Primary", style: .primary) { tap("Primary") }
                    CBButton("Secondary", style: .secondary) { tap("Secondary") }
                    CBButton("Tertiary", style: .tertiary) { tap("Tertiary") }
                    CBButton("Outline", style: .outline) { tap("Outline") }
                    CBButton("Ghost", style: .ghost) { tap("Ghost") }
                    CBButton("Destructive", style: .destructive) { tap("Destructive") }
                }

                section("Sizes") {
                    CBButton("Small", size: .small) { tap("Small") }
                    CBButton("Medium", size: .medium) { tap("Medium") }
                    CBButton("Large", size: .large) { tap("Large") }
                }

                section("Shapes") {
                    CBButton("Rounded", shape: .rounded) { tap("Rounded") }
                    CBButton("Capsule", shape: .capsule) { tap("Capsule") }
                    CBButton("Rectangle", shape: .rectangle) { tap("Rectangle") }
                }

                section("With icons") {
                    CBButton("Add item", icon: .leading(systemName: "plus")) { tap("Add item") }
                    CBButton("Continue", icon: .trailing(systemName: "arrow.right"), style: .outline) { tap("Continue") }
                    HStack(spacing: 12) {
                        CBButton("", icon: .only(systemName: "heart.fill"), style: .secondary) { tap("Heart") }
                        CBButton("", icon: .only(systemName: "square.and.arrow.up"), style: .secondary) { tap("Share") }
                        CBButton("", icon: .only(systemName: "trash"), style: .secondary, shape: .capsule) { tap("Delete") }
                    }
                }

                section("States") {
                    CBButton("Disabled", style: .primary) {}.disabled(true)
                    CBButton(
                        isLoadingDemo ? "Loading…" : "Tap to load",
                        style: .primary,
                        isLoading: isLoadingDemo
                    ) {
                        runLoadingDemo()
                    }
                }

                section("Full width") {
                    CBButton("Primary action", style: .primary, fullWidth: true) { tap("Full width primary") }
                    CBButton("Secondary action", style: .outline, fullWidth: true) { tap("Full width outline") }
                }
            }
            .padding(20)
            .animation(.easeInOut(duration: 0.2), value: lastTapped)
        }
        .navigationTitle("Button")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tap(_ name: String) {
        lastTapped = name
    }

    private func runLoadingDemo() {
        guard !isLoadingDemo else { return }
        isLoadingDemo = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            isLoadingDemo = false
            tap("Loading finished")
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ButtonGallery()
    }
}
