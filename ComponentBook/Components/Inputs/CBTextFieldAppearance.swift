import SwiftUI

/// Visual constants shared by every ``CBTextField`` rendering.
///
/// Grouped into a namespace so palette and layout numbers stay searchable and
/// Sonar's "no magic numbers" rule is satisfied at the call site.
enum TextFieldConstants {
    static let labelSpacing: CGFloat = 6
    static let helperIconSpacing: CGFloat = 4
    static let defaultBorderWidth: CGFloat = 1
    static let focusedBorderWidth: CGFloat = 2
    static let disabledOpacity: Double = 0.45
    static let focusAnimationDuration: TimeInterval = 0.15
}

/// Per-size visual metrics resolved from ``CBTextField/Size``.
///
/// Kept separate from the public ``CBTextField/Size`` enum so the rendering
/// table can grow (extra padding, alt fonts, density variants) without
/// touching the public API surface.
struct TextFieldMetrics {
    /// Minimum field height. The HStack uses `frame(minHeight:)` so Dynamic
    /// Type can grow it further without clipping.
    let height: CGFloat
    /// Inset on both leading and trailing edges of the field row.
    let horizontalPadding: CGFloat
    /// Container corner radius for ``CBTextField/Style/outlined`` and ``CBTextField/Style/filled``.
    let cornerRadius: CGFloat
    /// Spacing between icon, input and trailing affordance inside the row.
    let contentSpacing: CGFloat
    /// Font for the input itself.
    let font: Font
    /// Font for leading / trailing icons.
    let iconFont: Font
    /// Font for the optional top label.
    let labelFont: Font
    /// Font for the helper / validation message row.
    let helperFont: Font
}

extension CBTextField.Size {
    /// Visual metrics for this size.
    ///
    /// Heights respect Apple's 44pt minimum touch target on ``CBTextField/Size/medium``
    /// and ``CBTextField/Size/large``. ``CBTextField/Size/small`` is intentionally
    /// below that minimum and is for dense, inline editing contexts only.
    var metrics: TextFieldMetrics {
        switch self {
        case .small:
            return TextFieldMetrics(
                height: 36,
                horizontalPadding: 10,
                cornerRadius: 8,
                contentSpacing: 6,
                font: .footnote,
                iconFont: .footnote,
                labelFont: .caption.weight(.medium),
                helperFont: .caption2
            )
        case .medium:
            return TextFieldMetrics(
                height: 44,
                horizontalPadding: 12,
                cornerRadius: 10,
                contentSpacing: 8,
                font: .body,
                iconFont: .body,
                labelFont: .footnote.weight(.medium),
                helperFont: .caption
            )
        case .large:
            return TextFieldMetrics(
                height: 56,
                horizontalPadding: 16,
                cornerRadius: 12,
                contentSpacing: 10,
                font: .title3,
                iconFont: .title3,
                labelFont: .subheadline.weight(.medium),
                helperFont: .footnote
            )
        }
    }
}

extension CBTextField.ValidationState {

    /// Color applied to helper text and the inline validation icon.
    ///
    /// `Color.green` and `Color.red` are SwiftUI semantic colors that adapt
    /// for dark mode and increased-contrast environments automatically.
    var helperColor: Color {
        switch self {
        case .neutral: return .secondary
        case .success: return .green
        case .error: return .red
        }
    }

    /// SF Symbol shown before helper text. `nil` for ``CBTextField/ValidationState/neutral``.
    var helperIcon: String? {
        switch self {
        case .neutral: return nil
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        }
    }
}
