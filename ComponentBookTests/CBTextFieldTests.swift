import Testing
import SwiftUI
@testable import ComponentBook

@Suite("CBTextField")
struct CBTextFieldTests {

    // MARK: - Configuration defaults

    @Test("Default configuration matches text / outlined / medium / neutral / no decoration")
    func configurationDefaults() {
        let config = CBTextField.Configuration()
        #expect(config.variant == .text)
        #expect(config.style == .outlined)
        #expect(config.size == .medium)
        #expect(config.validationState == .neutral)
        #expect(config.helperText == nil)
        #expect(config.leadingIcon == nil)
        #expect(config.trailingIcon == nil)
        #expect(config.showsClearButton == false)
    }

    // MARK: - Size metrics

    @Test("Each size returns metrics with the documented height", arguments: [
        (CBTextField.Size.small, CGFloat(36)),
        (CBTextField.Size.medium, CGFloat(44)),
        (CBTextField.Size.large, CGFloat(56))
    ])
    func sizeMetricsHeights(size: CBTextField.Size, expectedHeight: CGFloat) {
        #expect(size.metrics.height == expectedHeight)
    }

    @Test("Medium and large meet Apple's 44pt minimum touch target")
    func mediumAndLargeMeetMinimumTouchTarget() {
        let appleMinimum: CGFloat = 44
        #expect(CBTextField.Size.medium.metrics.height >= appleMinimum)
        #expect(CBTextField.Size.large.metrics.height >= appleMinimum)
    }

    @Test("Horizontal padding and corner radius grow monotonically with size")
    func sizeMetricsAreMonotonic() {
        let small = CBTextField.Size.small.metrics
        let medium = CBTextField.Size.medium.metrics
        let large = CBTextField.Size.large.metrics
        #expect(small.horizontalPadding < medium.horizontalPadding)
        #expect(medium.horizontalPadding < large.horizontalPadding)
        #expect(small.cornerRadius < medium.cornerRadius)
        #expect(medium.cornerRadius < large.cornerRadius)
    }

    // MARK: - Validation state mapping

    @Test("Neutral state has no inline validation icon")
    func neutralHasNoHelperIcon() {
        #expect(CBTextField.ValidationState.neutral.helperIcon == nil)
    }

    @Test("Success and error states expose the documented SF Symbols", arguments: [
        (CBTextField.ValidationState.success, "checkmark.circle.fill"),
        (CBTextField.ValidationState.error, "exclamationmark.circle.fill")
    ])
    func helperIconNames(state: CBTextField.ValidationState, expected: String) {
        #expect(state.helperIcon == expected)
    }

    @Test("Helper colors map validation states to the documented semantic colors", arguments: [
        (CBTextField.ValidationState.neutral, Color.secondary),
        (CBTextField.ValidationState.success, Color.green),
        (CBTextField.ValidationState.error, Color.red)
    ])
    func helperColors(state: CBTextField.ValidationState, expected: Color) {
        #expect(state.helperColor == expected)
    }

    // MARK: - Variants are CaseIterable for documentation completeness

    @Test("All variants, styles, sizes and validation states are CaseIterable so gallery loops cover the surface")
    func enumsAreFullyEnumerable() {
        #expect(CBTextField.Variant.allCases.count == 2)
        #expect(CBTextField.Style.allCases.count == 3)
        #expect(CBTextField.Size.allCases.count == 3)
        #expect(CBTextField.ValidationState.allCases.count == 3)
    }
}
