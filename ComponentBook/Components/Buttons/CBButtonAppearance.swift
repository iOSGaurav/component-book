import SwiftUI

/// `ButtonStyle` that renders a ``CBButton`` according to its configuration.
///
/// Owns layout (padding, height, full-width), background/border via the
/// configured shape, press feedback (scale + dim), and the label content
/// (text + icon, or a tinted spinner when loading). Kept internal because
/// the public surface is the ``CBButton`` view itself.
struct CBButtonAppearance: ButtonStyle {

    let title: String
    let configuration: CBButton.Configuration

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration buttonContext: Configuration) -> some View {
        let metrics = configuration.size.metrics
        let palette = configuration.style.palette(pressed: buttonContext.isPressed)

        return label(metrics: metrics, foreground: palette.foreground)
            .padding(.horizontal, metrics.horizontalPadding)
            .frame(minHeight: metrics.height)
            .frame(maxWidth: configuration.fullWidth ? .infinity : nil)
            .background { shapeFill(metrics: metrics, color: palette.background) }
            .overlay { shapeStroke(metrics: metrics, color: palette.border, width: palette.borderWidth) }
            .opacity(isEnabled ? 1 : AppearanceConstants.disabledOpacity)
            .scaleEffect(buttonContext.isPressed ? AppearanceConstants.pressedScale : 1)
            .animation(.easeOut(duration: AppearanceConstants.pressAnimationDuration), value: buttonContext.isPressed)
            .contentShape(.rect)
    }

    @ViewBuilder
    private func label(metrics: SizeMetrics, foreground: Color) -> some View {
        if configuration.isLoading {
            ProgressView()
                .controlSize(metrics.spinnerSize)
                .tint(foreground)
        } else {
            HStack(spacing: metrics.iconSpacing) {
                if case .leading(let name) = configuration.icon {
                    Image(systemName: name).font(metrics.iconFont)
                }
                if case .only(let name) = configuration.icon {
                    Image(systemName: name).font(metrics.iconFont)
                } else {
                    Text(title).font(metrics.font)
                }
                if case .trailing(let name) = configuration.icon {
                    Image(systemName: name).font(metrics.iconFont)
                }
            }
            .foregroundStyle(foreground)
        }
    }

    @ViewBuilder
    private func shapeFill(metrics: SizeMetrics, color: Color) -> some View {
        switch configuration.shape {
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
            switch configuration.shape {
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

/// Visual constants shared by every ``CBButton`` rendering.
enum AppearanceConstants {
    static let disabledOpacity: Double = 0.45
    static let pressedScale: CGFloat = 0.97
    static let pressAnimationDuration: TimeInterval = 0.12
}

/// Per-size visual metrics resolved from ``CBButton/Size``.
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
    /// Visual metrics for this size.
    var metrics: SizeMetrics {
        switch self {
        case .small:
            return SizeMetrics(
                height: 32,
                horizontalPadding: 12,
                cornerRadius: 8,
                font: .footnote.weight(.semibold),
                iconFont: .footnote.weight(.semibold),
                iconSpacing: 6,
                spinnerSize: .small
            )
        case .medium:
            return SizeMetrics(
                height: 44,
                horizontalPadding: 16,
                cornerRadius: 10,
                font: .body.weight(.semibold),
                iconFont: .body.weight(.semibold),
                iconSpacing: 8,
                spinnerSize: .regular
            )
        case .large:
            return SizeMetrics(
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

/// Colors resolved from ``CBButton/Style`` for a given press state.
struct StylePalette {
    let background: Color
    let foreground: Color
    let border: Color
    let borderWidth: CGFloat
}

extension CBButton.Style {

    /// Color palette for this style.
    ///
    /// - Parameter pressed: Whether the button is currently pressed.
    /// - Returns: The resolved palette of background, foreground and border colors.
    func palette(pressed: Bool) -> StylePalette {
        switch self {
        case .primary:
            return StylePalette(
                background: pressed ? Color.accentColor.opacity(PaletteOpacity.pressedFilled) : .accentColor,
                foreground: .white,
                border: .clear,
                borderWidth: 0
            )
        case .secondary:
            return StylePalette(
                background: Color.accentColor.opacity(pressed ? PaletteOpacity.secondaryPressed : PaletteOpacity.secondary),
                foreground: .accentColor,
                border: .clear,
                borderWidth: 0
            )
        case .tertiary:
            return StylePalette(
                background: pressed ? Color.primary.opacity(PaletteOpacity.pressedGhost) : .clear,
                foreground: .accentColor,
                border: .clear,
                borderWidth: 0
            )
        case .outline:
            return StylePalette(
                background: pressed ? Color.accentColor.opacity(PaletteOpacity.pressedGhost) : .clear,
                foreground: .accentColor,
                border: .accentColor,
                borderWidth: PaletteMetrics.outlineBorderWidth
            )
        case .ghost:
            return StylePalette(
                background: pressed ? Color.primary.opacity(PaletteOpacity.pressedGhost) : .clear,
                foreground: .primary,
                border: .clear,
                borderWidth: 0
            )
        case .destructive:
            return StylePalette(
                background: pressed ? Color.red.opacity(PaletteOpacity.pressedFilled) : .red,
                foreground: .white,
                border: .clear,
                borderWidth: 0
            )
        }
    }
}

/// Opacity constants used by ``CBButton/Style/palette(pressed:)``.
private enum PaletteOpacity {
    static let pressedFilled: Double = 0.82
    static let secondary: Double = 0.15
    static let secondaryPressed: Double = 0.25
    static let pressedGhost: Double = 0.08
}

/// Layout constants used by ``CBButton/Style/palette(pressed:)``.
private enum PaletteMetrics {
    static let outlineBorderWidth: CGFloat = 1.5
}
