import SwiftUI

/// Catalog screen demoing every ``CBButton`` configuration variant.
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

                stylesSection
                sizesSection
                shapesSection
                iconsSection
                statesSection
                fullWidthSection
            }
            .padding(20)
            .animation(.easeInOut(duration: 0.2), value: lastTapped)
        }
        .navigationTitle("Button")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var stylesSection: some View {
        section("Styles") {
            CBButton("Primary", configuration: .init(style: .primary)) { tap("Primary") }
            CBButton("Secondary", configuration: .init(style: .secondary)) { tap("Secondary") }
            CBButton("Tertiary", configuration: .init(style: .tertiary)) { tap("Tertiary") }
            CBButton("Outline", configuration: .init(style: .outline)) { tap("Outline") }
            CBButton("Ghost", configuration: .init(style: .ghost)) { tap("Ghost") }
            CBButton(
                "Destructive",
                configuration: .init(
                    style: .destructive,
                    accessibilityHint: "Performs a destructive action"
                )
            ) { tap("Destructive") }
        }
    }

    private var sizesSection: some View {
        section("Sizes") {
            CBButton("Small", configuration: .init(size: .small)) { tap("Small") }
            CBButton("Medium", configuration: .init(size: .medium)) { tap("Medium") }
            CBButton("Large", configuration: .init(size: .large)) { tap("Large") }
        }
    }

    private var shapesSection: some View {
        section("Shapes") {
            CBButton("Rounded", configuration: .init(shape: .rounded)) { tap("Rounded") }
            CBButton("Capsule", configuration: .init(shape: .capsule)) { tap("Capsule") }
            CBButton("Rectangle", configuration: .init(shape: .rectangle)) { tap("Rectangle") }
        }
    }

    private var iconsSection: some View {
        section("With icons") {
            CBButton(
                "Add item",
                configuration: .init(icon: .leading(systemName: "plus"))
            ) { tap("Add item") }
            CBButton(
                "Continue",
                configuration: .init(
                    style: .outline,
                    icon: .trailing(systemName: "arrow.right")
                )
            ) { tap("Continue") }
            HStack(spacing: 12) {
                CBButton(
                    "",
                    configuration: .init(
                        style: .secondary,
                        icon: .only(systemName: "heart.fill"),
                        accessibilityLabel: "Favorite"
                    )
                ) { tap("Favorite") }
                CBButton(
                    "",
                    configuration: .init(
                        style: .secondary,
                        icon: .only(systemName: "square.and.arrow.up"),
                        accessibilityLabel: "Share"
                    )
                ) { tap("Share") }
                CBButton(
                    "",
                    configuration: .init(
                        style: .secondary,
                        shape: .capsule,
                        icon: .only(systemName: "trash"),
                        accessibilityLabel: "Delete",
                        accessibilityHint: "Permanently deletes the item"
                    )
                ) { tap("Delete") }
            }
        }
    }

    private var statesSection: some View {
        section("States") {
            CBButton("Disabled", configuration: .init(style: .primary)) {}
                .disabled(true)
            CBButton(
                isLoadingDemo ? "Loading…" : "Tap to load",
                configuration: .init(style: .primary, isLoading: isLoadingDemo)
            ) {
                runLoadingDemo()
            }
        }
    }

    private var fullWidthSection: some View {
        section("Full width") {
            CBButton(
                "Primary action",
                configuration: .init(style: .primary, fullWidth: true)
            ) { tap("Full width primary") }
            CBButton(
                "Secondary action",
                configuration: .init(style: .outline, fullWidth: true)
            ) { tap("Full width outline") }
        }
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
