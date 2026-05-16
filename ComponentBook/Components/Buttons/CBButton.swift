import SwiftUI

/// A fully configurable SwiftUI button used throughout the ComponentBook catalog.
///
/// Visual and behavioural options are grouped into ``Configuration`` so the
/// initializer keeps a small parameter count. Defaults match the most common
/// "primary, medium, rounded, no icon" usage; only override what differs.
///
///     CBButton("Save") { save() }
///
///     CBButton(
///         "Continue",
///         configuration: .init(
///             style: .outline,
///             icon: .trailing(systemName: "arrow.right")
///         )
///     ) { advance() }
///
/// Accessibility: the visible title is used as the VoiceOver label by default.
/// For ``Icon/only(systemName:)`` buttons set
/// ``Configuration/accessibilityLabel`` to a meaningful description — VoiceOver
/// cannot infer intent from an SF Symbol name. Use
/// ``Configuration/accessibilityHint`` to clarify the effect of activation when
/// the label alone is not enough (e.g. destructive actions).
public struct CBButton: View {

    /// Visual emphasis of the button.
    public enum Style: Hashable, CaseIterable, Sendable {
        case primary
        case secondary
        case tertiary
        case outline
        case ghost
        case destructive
    }

    /// Vertical scale — drives height, padding, font and spinner size.
    public enum Size: Hashable, CaseIterable, Sendable {
        case small
        case medium
        case large
    }

    /// Outer corner geometry.
    public enum Shape: Hashable, CaseIterable, Sendable {
        case rounded
        case capsule
        case rectangle
    }

    /// Optional SF Symbol companion to the title.
    public enum Icon: Hashable, Sendable {
        /// No icon.
        case none
        /// Symbol shown before the title.
        case leading(systemName: String)
        /// Symbol shown after the title.
        case trailing(systemName: String)
        /// Symbol only, no visible title. Pair with
        /// ``Configuration/accessibilityLabel`` so VoiceOver can announce intent.
        case only(systemName: String)
    }

    /// All non-essential options grouped into one value so the initializer stays
    /// within Sonar's max-parameter limit and unused options stay invisible at
    /// the call site.
    public struct Configuration: Hashable, Sendable {

        /// Visual emphasis. Defaults to ``Style/primary``.
        public var style: Style

        /// Size scale. Defaults to ``Size/medium``.
        public var size: Size

        /// Corner geometry. Defaults to ``Shape/rounded``.
        public var shape: Shape

        /// Optional SF Symbol companion to the title. Defaults to ``Icon/none``.
        public var icon: Icon

        /// When `true`, expands to fill the available horizontal width.
        public var fullWidth: Bool

        /// When `true`, replaces the label with a tinted progress spinner and
        /// disables the tap target. VoiceOver announces the button's value as
        /// "Loading" so users on assistive tech know to wait.
        public var isLoading: Bool

        /// Overrides the VoiceOver label. Required when using ``Icon/only`` —
        /// VoiceOver has no visible text to read otherwise.
        public var accessibilityLabel: String?

        /// Optional VoiceOver hint describing the effect of activation
        /// (e.g. "Permanently deletes the item").
        public var accessibilityHint: String?

        /// Creates a configuration. Every option has a default so callers only
        /// set what differs from the standard look.
        ///
        /// - Parameters:
        ///   - style: Visual emphasis. Defaults to ``Style/primary``.
        ///   - size: Size scale. Defaults to ``Size/medium``.
        ///   - shape: Corner geometry. Defaults to ``Shape/rounded``.
        ///   - icon: Optional SF Symbol companion. Defaults to ``Icon/none``.
        ///   - fullWidth: Expand to fill the available horizontal width.
        ///   - isLoading: Show a spinner and block taps.
        ///   - accessibilityLabel: Override the VoiceOver label.
        ///   - accessibilityHint: VoiceOver hint describing the effect.
        public init(
            style: Style = .primary,
            size: Size = .medium,
            shape: Shape = .rounded,
            icon: Icon = .none,
            fullWidth: Bool = false,
            isLoading: Bool = false,
            accessibilityLabel: String? = nil,
            accessibilityHint: String? = nil
        ) {
            self.style = style
            self.size = size
            self.shape = shape
            self.icon = icon
            self.fullWidth = fullWidth
            self.isLoading = isLoading
            self.accessibilityLabel = accessibilityLabel
            self.accessibilityHint = accessibilityHint
        }
    }

    private let title: String
    private let configuration: Configuration
    private let action: () -> Void

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The visible label. May be empty when using ``Icon/only(systemName:)``.
    ///   - configuration: Visual and behavioural options. Defaults to the
    ///     standard primary / medium / rounded look.
    ///   - action: Invoked when the user taps the button. Not called while
    ///     ``Configuration/isLoading`` is `true`.
    public init(
        _ title: String,
        configuration: Configuration = .init(),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.configuration = configuration
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            EmptyView()
        }
        .buttonStyle(CBButtonAppearance(title: title, configuration: configuration))
        .disabled(configuration.isLoading)
        .accessibilityLabel(Text(resolvedAccessibilityLabel))
        .accessibilityHint(Text(configuration.accessibilityHint ?? ""))
        .accessibilityValue(Text(configuration.isLoading ? "Loading" : ""))
    }

    /// VoiceOver label fallback chain: explicit override → title → SF Symbol name.
    private var resolvedAccessibilityLabel: String {
        if let override = configuration.accessibilityLabel, !override.isEmpty {
            return override
        }
        if !title.isEmpty {
            return title
        }
        if case .only(let systemName) = configuration.icon {
            return systemName.replacingOccurrences(of: ".", with: " ")
        }
        return ""
    }
}

#Preview("Variants") {
    ScrollView {
        VStack(spacing: 12) {
            CBButton("Primary") {}
            CBButton("Secondary", configuration: .init(style: .secondary)) {}
            CBButton("Tertiary", configuration: .init(style: .tertiary)) {}
            CBButton("Outline", configuration: .init(style: .outline)) {}
            CBButton("Ghost", configuration: .init(style: .ghost)) {}
            CBButton(
                "Delete",
                configuration: .init(
                    style: .destructive,
                    accessibilityHint: "Permanently deletes the item"
                )
            ) {}
            CBButton(
                "Save",
                configuration: .init(icon: .leading(systemName: "checkmark"))
            ) {}
            CBButton(
                "",
                configuration: .init(
                    style: .secondary,
                    icon: .only(systemName: "heart.fill"),
                    accessibilityLabel: "Favorite"
                )
            ) {}
            CBButton("Full Width", configuration: .init(fullWidth: true)) {}
            CBButton("Loading", configuration: .init(isLoading: true)) {}
            CBButton("Disabled") {}.disabled(true)
        }
        .padding()
    }
}
