import SwiftUI

/// A fully configurable SwiftUI text input used throughout the ComponentBook catalog.
///
/// Visual and behavioural options are grouped into ``Configuration`` so the
/// initializer keeps a small parameter count and unused options stay invisible
/// at the call site. Defaults match the most common "text, outlined, medium,
/// neutral validation, no icons" usage.
///
///     CBTextField("Email", placeholder: "you@example.com", text: $email)
///
///     CBTextField(
///         "Password",
///         placeholder: "At least 8 characters",
///         text: $password,
///         configuration: .init(
///             variant: .secure,
///             leadingIcon: "lock",
///             validationState: passwordError == nil ? .neutral : .error,
///             helperText: passwordError ?? "Use letters, numbers, and a symbol"
///         )
///     )
///
/// Standard SwiftUI text-input modifiers — `.keyboardType`, `.textContentType`,
/// `.submitLabel`, `.onSubmit`, `.focused`, `.autocorrectionDisabled`,
/// `.textInputAutocapitalization` — propagate through the wrapper to the
/// underlying `TextField` / `SecureField`, so configuration covers visual
/// concerns only.
///
/// Accessibility & Apple HIG:
/// - The optional top label is the VoiceOver label by default.
/// - When ``Configuration/validationState`` is ``ValidationState/error``,
///   VoiceOver announces "Error" as the value and the helper text becomes
///   the hint so the cause is read on focus.
/// - The clear button (when shown) is announced as "Clear text".
/// - All colors use semantic system tokens (`Color(.separator)`,
///   `Color(.secondarySystemBackground)`, `.accentColor`, `.red`, `.green`),
///   so dark mode and increased-contrast environments work without extra
///   configuration.
/// - Heights respect the 44pt minimum touch target on ``Size/medium`` and
///   ``Size/large``. ``Size/small`` (36pt) is intended for dense layouts
///   like inline editors and stays close enough to remain usable with
///   accessibility settings.
/// - Fonts are semantic (`.body`, `.footnote`, `.caption`), so Dynamic Type
///   scales the entire field including the helper row.
public struct CBTextField: View {

    /// Type of input the field accepts.
    public enum Variant: Hashable, CaseIterable, Sendable {
        /// Standard editable text. Backed by `TextField`.
        case text
        /// Masked password input. Backed by `SecureField`.
        case secure
    }

    /// Visual treatment of the field's container.
    public enum Style: Hashable, CaseIterable, Sendable {
        /// Border-only, transparent background — the classic iOS form-row look.
        case outlined
        /// Tinted background, no border (subtle accent border on focus).
        case filled
        /// Bottom border only — a flat, low-emphasis variant for dense forms.
        case underlined
    }

    /// Vertical scale — drives height, padding, font and icon size.
    public enum Size: Hashable, CaseIterable, Sendable {
        case small
        case medium
        case large
    }

    /// Validation tone applied to the border and helper text.
    public enum ValidationState: Hashable, CaseIterable, Sendable {
        case neutral
        case success
        case error
    }

    /// All non-essential options grouped into one value so the initializer
    /// stays within Sonar's max-parameter limit.
    public struct Configuration: Hashable, Sendable {

        /// Input type. Defaults to ``Variant/text``.
        public var variant: Variant

        /// Container treatment. Defaults to ``Style/outlined``.
        public var style: Style

        /// Size scale. Defaults to ``Size/medium``.
        public var size: Size

        /// Validation tone applied to the border and helper text. Defaults to
        /// ``ValidationState/neutral``.
        public var validationState: ValidationState

        /// Optional auxiliary text shown beneath the field. Styled by
        /// ``validationState`` (red on error, green on success, secondary
        /// otherwise). Also exposed as the VoiceOver hint.
        public var helperText: String?

        /// SF Symbol shown inside the field, before the input.
        public var leadingIcon: String?

        /// SF Symbol shown inside the field, after the input. Hidden while a
        /// non-empty value is shown and ``showsClearButton`` is on, to avoid
        /// two trailing affordances competing for the same space.
        public var trailingIcon: String?

        /// When `true`, displays a trailing "X" while the field has content.
        public var showsClearButton: Bool

        /// Creates a configuration. Every option has a default so callers
        /// only set what differs from the standard look.
        ///
        /// - Parameters:
        ///   - variant: Input type.
        ///   - style: Container treatment.
        ///   - size: Size scale.
        ///   - validationState: Validation tone.
        ///   - helperText: Auxiliary text shown beneath the field.
        ///   - leadingIcon: SF Symbol shown before the input.
        ///   - trailingIcon: SF Symbol shown after the input.
        ///   - showsClearButton: Display a trailing clear button when text exists.
        public init(
            variant: Variant = .text,
            style: Style = .outlined,
            size: Size = .medium,
            validationState: ValidationState = .neutral,
            helperText: String? = nil,
            leadingIcon: String? = nil,
            trailingIcon: String? = nil,
            showsClearButton: Bool = false
        ) {
            self.variant = variant
            self.style = style
            self.size = size
            self.validationState = validationState
            self.helperText = helperText
            self.leadingIcon = leadingIcon
            self.trailingIcon = trailingIcon
            self.showsClearButton = showsClearButton
        }
    }

    @Binding private var text: String
    private let label: String?
    private let placeholder: String
    private let configuration: Configuration

    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled

    /// Creates a text field.
    ///
    /// - Parameters:
    ///   - label: Optional top label shown above the field. Used as the
    ///     VoiceOver label by default.
    ///   - placeholder: Placeholder shown inside the empty field.
    ///   - text: Binding to the entered value.
    ///   - configuration: Visual and behavioural options.
    public init(
        _ label: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        configuration: Configuration = .init()
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: TextFieldConstants.labelSpacing) {
            if let label, !label.isEmpty {
                Text(label)
                    .font(metrics.labelFont)
                    .foregroundStyle(.secondary)
            }
            fieldRow
            if let helper = configuration.helperText, !helper.isEmpty {
                helperRow(text: helper)
            }
        }
        .opacity(isEnabled ? 1 : TextFieldConstants.disabledOpacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(resolvedAccessibilityLabel))
        .accessibilityValue(Text(resolvedAccessibilityValue))
        .accessibilityHint(Text(configuration.helperText ?? ""))
    }

    private var metrics: TextFieldMetrics { configuration.size.metrics }

    private var fieldRow: some View {
        HStack(spacing: metrics.contentSpacing) {
            if let leading = configuration.leadingIcon {
                Image(systemName: leading)
                    .font(metrics.iconFont)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            inputField
            trailingAffordance
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .frame(minHeight: metrics.height)
        .background { fieldBackground }
        .overlay { fieldBorder }
        .animation(.easeOut(duration: TextFieldConstants.focusAnimationDuration), value: isFocused)
        .animation(.easeOut(duration: TextFieldConstants.focusAnimationDuration), value: configuration.validationState)
    }

    @ViewBuilder
    private var inputField: some View {
        switch configuration.variant {
        case .text:
            TextField(placeholder, text: $text)
                .font(metrics.font)
                .focused($isFocused)
        case .secure:
            SecureField(placeholder, text: $text)
                .font(metrics.font)
                .focused($isFocused)
        }
    }

    @ViewBuilder
    private var trailingAffordance: some View {
        if configuration.showsClearButton, !text.isEmpty {
            Button {
                text = ""
                isFocused = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(metrics.iconFont)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear text")
        } else if let trailing = configuration.trailingIcon {
            Image(systemName: trailing)
                .font(metrics.iconFont)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var fieldBackground: some View {
        switch configuration.style {
        case .outlined, .underlined:
            EmptyView()
        case .filled:
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        }
    }

    @ViewBuilder
    private var fieldBorder: some View {
        let color = borderColor
        let width = borderWidth
        switch configuration.style {
        case .outlined, .filled:
            RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                .strokeBorder(color, lineWidth: width)
        case .underlined:
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Rectangle()
                    .fill(color)
                    .frame(height: width)
            }
        }
    }

    private var borderColor: Color {
        switch configuration.validationState {
        case .neutral:
            return isFocused ? .accentColor : Color(.separator)
        case .success:
            return .green
        case .error:
            return .red
        }
    }

    private var borderWidth: CGFloat {
        let prominent = isFocused || configuration.validationState != .neutral
        return prominent ? TextFieldConstants.focusedBorderWidth : TextFieldConstants.defaultBorderWidth
    }

    @ViewBuilder
    private func helperRow(text: String) -> some View {
        HStack(spacing: TextFieldConstants.helperIconSpacing) {
            if let icon = configuration.validationState.helperIcon {
                Image(systemName: icon)
                    .font(metrics.helperFont)
                    .accessibilityHidden(true)
            }
            Text(text)
                .font(metrics.helperFont)
        }
        .foregroundStyle(configuration.validationState.helperColor)
    }

    private var resolvedAccessibilityLabel: String {
        if let label, !label.isEmpty { return label }
        return placeholder
    }

    private var resolvedAccessibilityValue: String {
        if configuration.validationState == .error { return "Error" }
        if text.isEmpty { return "Empty" }
        if configuration.variant == .secure { return "Secure" }
        return text
    }
}

#Preview("Variants") {
    @Previewable @State var text = ""
    @Previewable @State var password = ""
    @Previewable @State var search = ""

    ScrollView {
        VStack(spacing: 16) {
            CBTextField("Email", placeholder: "you@example.com", text: $text)
            CBTextField(
                "Password",
                placeholder: "At least 8 characters",
                text: $password,
                configuration: .init(variant: .secure, leadingIcon: "lock")
            )
            CBTextField(
                "Search",
                placeholder: "Search the catalog",
                text: $search,
                configuration: .init(
                    style: .filled,
                    leadingIcon: "magnifyingglass",
                    showsClearButton: true
                )
            )
            CBTextField(
                "Username",
                placeholder: "Choose a username",
                text: .constant("alice"),
                configuration: .init(validationState: .success, helperText: "Available")
            )
            CBTextField(
                "Email",
                placeholder: "you@example.com",
                text: .constant("not-an-email"),
                configuration: .init(validationState: .error, helperText: "Enter a valid email")
            )
        }
        .padding()
    }
}
