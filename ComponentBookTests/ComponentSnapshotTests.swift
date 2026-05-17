import XCTest
import SwiftUI
import SnapshotTesting
@testable import ComponentBook

/// Snapshot tests for both component galleries.
///
/// Snapshots are stored under `ComponentBookTests/__Snapshots__/` and asserted
/// against on every subsequent run. To regenerate them after an intentional
/// visual change, set the `SNAPSHOT_TESTING_RECORD=missing` (record only what
/// is missing) or `=all` environment variable on the scheme's test action, or
/// temporarily flip `withSnapshotTesting(record: .all)` below to a non-`.never`
/// mode for the run that should re-record.
@MainActor
final class ComponentSnapshotTests: XCTestCase {

    private let renderSize = CGSize(width: 320, height: 120)

    // MARK: - CBButton

    func test_buttonPrimary_default() {
        let view = wrap(CBButton("Primary") {})
        assertSnapshot(of: view, as: .image(layout: .fixed(width: renderSize.width, height: renderSize.height)))
    }

    func test_buttonSecondary() {
        let view = wrap(CBButton("Secondary", configuration: .init(style: .secondary)) {})
        assertSnapshot(of: view, as: .image(layout: .fixed(width: renderSize.width, height: renderSize.height)))
    }

    func test_buttonOutline_withLeadingIcon() {
        let button = CBButton(
            "Continue",
            configuration: .init(
                style: .outline,
                icon: .leading(systemName: "checkmark")
            )
        ) {}
        assertSnapshot(of: wrap(button), as: .image(layout: .fixed(width: renderSize.width, height: renderSize.height)))
    }

    func test_buttonDestructive_loading() {
        let button = CBButton(
            "Delete",
            configuration: .init(style: .destructive, isLoading: true)
        ) {}
        assertSnapshot(of: wrap(button), as: .image(layout: .fixed(width: renderSize.width, height: renderSize.height)))
    }

    func test_buttonIconOnly_capsule() {
        let button = CBButton(
            "",
            configuration: .init(
                style: .secondary,
                shape: .capsule,
                icon: .only(systemName: "heart.fill"),
                accessibilityLabel: "Favorite"
            )
        ) {}
        assertSnapshot(of: wrap(button), as: .image(layout: .fixed(width: 120, height: renderSize.height)))
    }

    func test_buttonAllSizes() {
        let stack = VStack(spacing: 12) {
            CBButton("Small", configuration: .init(size: .small)) {}
            CBButton("Medium", configuration: .init(size: .medium)) {}
            CBButton("Large", configuration: .init(size: .large)) {}
        }
        assertSnapshot(of: wrap(stack), as: .image(layout: .fixed(width: renderSize.width, height: 260)))
    }

    func test_buttonAllShapes() {
        let stack = VStack(spacing: 12) {
            CBButton("Rounded", configuration: .init(shape: .rounded)) {}
            CBButton("Capsule", configuration: .init(shape: .capsule)) {}
            CBButton("Rectangle", configuration: .init(shape: .rectangle)) {}
        }
        assertSnapshot(of: wrap(stack), as: .image(layout: .fixed(width: renderSize.width, height: 220)))
    }

    func test_buttonFullWidth() {
        let button = CBButton("Primary action", configuration: .init(fullWidth: true)) {}
        assertSnapshot(of: wrap(button), as: .image(layout: .fixed(width: renderSize.width, height: renderSize.height)))
    }

    // MARK: - CBTextField

    func test_textFieldOutlined_empty() {
        let field = CBTextField("Email", placeholder: "you@example.com", text: .constant(""))
        assertSnapshot(of: wrap(field), as: .image(layout: .fixed(width: renderSize.width, height: 100)))
    }

    func test_textFieldFilled_withSearchIcon_andClear() {
        let field = CBTextField(
            "Search",
            placeholder: "Search the catalog",
            text: .constant("query"),
            configuration: .init(
                style: .filled,
                leadingIcon: "magnifyingglass",
                showsClearButton: true
            )
        )
        assertSnapshot(of: wrap(field), as: .image(layout: .fixed(width: renderSize.width, height: 100)))
    }

    func test_textFieldUnderlined() {
        let field = CBTextField(
            "Bio",
            placeholder: "Tell us about yourself",
            text: .constant("Hello"),
            configuration: .init(style: .underlined)
        )
        assertSnapshot(of: wrap(field), as: .image(layout: .fixed(width: renderSize.width, height: 100)))
    }

    func test_textFieldValidationError() {
        let field = CBTextField(
            "Email",
            placeholder: "you@example.com",
            text: .constant("not-an-email"),
            configuration: .init(validationState: .error, helperText: "Enter a valid email")
        )
        assertSnapshot(of: wrap(field), as: .image(layout: .fixed(width: renderSize.width, height: 130)))
    }

    func test_textFieldValidationSuccess() {
        let field = CBTextField(
            "Username",
            placeholder: "Choose a username",
            text: .constant("alice"),
            configuration: .init(validationState: .success, helperText: "Available")
        )
        assertSnapshot(of: wrap(field), as: .image(layout: .fixed(width: renderSize.width, height: 130)))
    }

    func test_textFieldSecure_withLeadingIcon() {
        let field = CBTextField(
            "Password",
            placeholder: "At least 8 characters",
            text: .constant("p4ssw0rd"),
            configuration: .init(variant: .secure, leadingIcon: "lock")
        )
        assertSnapshot(of: wrap(field), as: .image(layout: .fixed(width: renderSize.width, height: 100)))
    }

    func test_textFieldAllSizes() {
        let stack = VStack(spacing: 16) {
            CBTextField("Small", placeholder: "Dense", text: .constant(""), configuration: .init(size: .small))
            CBTextField("Medium", placeholder: "Default", text: .constant(""), configuration: .init(size: .medium))
            CBTextField("Large", placeholder: "Prominent", text: .constant(""), configuration: .init(size: .large))
        }
        assertSnapshot(of: wrap(stack), as: .image(layout: .fixed(width: renderSize.width, height: 320)))
    }

    // MARK: - Helpers

    private func wrap<V: View>(_ view: V) -> some View {
        view
            .padding(16)
            .background(Color(.systemBackground))
    }
}
