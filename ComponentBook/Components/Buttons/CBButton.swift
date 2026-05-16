import SwiftUI

public struct CBButton: View {
    public enum Style: Hashable, CaseIterable, Sendable {
        case primary
        case secondary
        case tertiary
        case outline
        case ghost
        case destructive
    }

    public enum Size: Hashable, CaseIterable, Sendable {
        case small
        case medium
        case large
    }

    public enum Shape: Hashable, CaseIterable, Sendable {
        case rounded
        case capsule
        case rectangle
    }

    public enum Icon: Hashable, Sendable {
        case none
        case leading(systemName: String)
        case trailing(systemName: String)
        case only(systemName: String)
    }

    private let title: String
    private let icon: Icon
    private let style: Style
    private let size: Size
    private let shape: Shape
    private let fullWidth: Bool
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: Icon = .none,
        style: Style = .primary,
        size: Size = .medium,
        shape: Shape = .rounded,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.shape = shape
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            EmptyView()
        }
        .buttonStyle(
            CBButtonAppearance(
                title: title,
                icon: icon,
                style: style,
                size: size,
                shape: shape,
                fullWidth: fullWidth,
                isLoading: isLoading
            )
        )
        .disabled(isLoading)
        .accessibilityLabel(Text(accessibilityTitle))
    }

    private var accessibilityTitle: String {
        if case .only(let symbol) = icon, title.isEmpty {
            return symbol.replacingOccurrences(of: ".", with: " ")
        }
        return title
    }
}

private struct CBButtonAppearance: ButtonStyle {
    let title: String
    let icon: CBButton.Icon
    let style: CBButton.Style
    let size: CBButton.Size
    let shape: CBButton.Shape
    let fullWidth: Bool
    let isLoading: Bool

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let metrics = size.metrics
        let palette = style.palette(pressed: configuration.isPressed)

        return label(metrics: metrics, foreground: palette.foreground)
            .padding(.horizontal, metrics.horizontalPadding)
            .frame(minHeight: metrics.height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background {
                shapeFill(metrics: metrics, color: palette.background)
            }
            .overlay {
                shapeStroke(metrics: metrics, color: palette.border, width: palette.borderWidth)
            }
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .contentShape(.rect)
    }

    @ViewBuilder
    private func label(metrics: SizeMetrics, foreground: Color) -> some View {
        if isLoading {
            ProgressView()
                .controlSize(metrics.spinnerSize)
                .tint(foreground)
        } else {
            HStack(spacing: metrics.iconSpacing) {
                if case .leading(let name) = icon {
                    Image(systemName: name).font(metrics.iconFont)
                }
                if case .only(let name) = icon {
                    Image(systemName: name).font(metrics.iconFont)
                } else {
                    Text(title).font(metrics.font)
                }
                if case .trailing(let name) = icon {
                    Image(systemName: name).font(metrics.iconFont)
                }
            }
            .foregroundStyle(foreground)
        }
    }

    @ViewBuilder
    private func shapeFill(metrics: SizeMetrics, color: Color) -> some View {
        switch shape {
        case .rounded:
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous).fill(color)
        case .capsule:
            Capsule(style: .continuous).fill(color)
        case .rectangle:
            Rectangle().fill(color)
        }
    }

    @ViewBuilder
    private func shapeStroke(metrics: SizeMetrics, color: Color, width: CGFloat) -> some View {
        if width > 0 {
            switch shape {
            case .rounded:
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .strokeBorder(color, lineWidth: width)
            case .capsule:
                Capsule(style: .continuous).strokeBorder(color, lineWidth: width)
            case .rectangle:
                Rectangle().strokeBorder(color, lineWidth: width)
            }
        }
    }
}

struct SizeMetrics {
    let height: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let font: Font
    let iconFont: Font
    let iconSpacing: CGFloat
    let spinnerSize: ControlSize
}

extension CBButton.Size {
    var metrics: SizeMetrics {
        switch self {
        case .small:
            SizeMetrics(
                height: 32,
                horizontalPadding: 12,
                cornerRadius: 8,
                font: .footnote.weight(.semibold),
                iconFont: .footnote.weight(.semibold),
                iconSpacing: 6,
                spinnerSize: .small
            )
        case .medium:
            SizeMetrics(
                height: 44,
                horizontalPadding: 16,
                cornerRadius: 10,
                font: .body.weight(.semibold),
                iconFont: .body.weight(.semibold),
                iconSpacing: 8,
                spinnerSize: .regular
            )
        case .large:
            SizeMetrics(
                height: 56,
                horizontalPadding: 20,
                cornerRadius: 14,
                font: .title3.weight(.semibold),
                iconFont: .title3.weight(.semibold),
                iconSpacing: 10,
                spinnerSize: .large
            )
        }
    }
}

struct StylePalette {
    let background: Color
    let foreground: Color
    let border: Color
    let borderWidth: CGFloat
}

extension CBButton.Style {
    func palette(pressed: Bool) -> StylePalette {
        switch self {
        case .primary:
            StylePalette(
                background: pressed ? Color.accentColor.opacity(0.82) : .accentColor,
                foreground: .white,
                border: .clear,
                borderWidth: 0
            )
        case .secondary:
            StylePalette(
                background: Color.accentColor.opacity(pressed ? 0.25 : 0.15),
                foreground: .accentColor,
                border: .clear,
                borderWidth: 0
            )
        case .tertiary:
            StylePalette(
                background: pressed ? Color.primary.opacity(0.08) : .clear,
                foreground: .accentColor,
                border: .clear,
                borderWidth: 0
            )
        case .outline:
            StylePalette(
                background: pressed ? Color.accentColor.opacity(0.08) : .clear,
                foreground: .accentColor,
                border: .accentColor,
                borderWidth: 1.5
            )
        case .ghost:
            StylePalette(
                background: pressed ? Color.primary.opacity(0.08) : .clear,
                foreground: .primary,
                border: .clear,
                borderWidth: 0
            )
        case .destructive:
            StylePalette(
                background: pressed ? Color.red.opacity(0.82) : .red,
                foreground: .white,
                border: .clear,
                borderWidth: 0
            )
        }
    }
}

#Preview("Variants") {
    ScrollView {
        VStack(spacing: 12) {
            CBButton("Primary", style: .primary) {}
            CBButton("Secondary", style: .secondary) {}
            CBButton("Tertiary", style: .tertiary) {}
            CBButton("Outline", style: .outline) {}
            CBButton("Ghost", style: .ghost) {}
            CBButton("Destructive", style: .destructive) {}
            CBButton("Save", icon: .leading(systemName: "checkmark"), style: .primary) {}
            CBButton("Continue", icon: .trailing(systemName: "arrow.right"), style: .outline) {}
            CBButton("", icon: .only(systemName: "heart.fill"), style: .secondary) {}
            CBButton("Full Width", style: .primary, fullWidth: true) {}
            CBButton("Loading", style: .primary, isLoading: true) {}
            CBButton("Disabled", style: .primary) {}.disabled(true)
        }
        .padding()
    }
}
