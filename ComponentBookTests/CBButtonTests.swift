import Testing
import SwiftUI
@testable import ComponentBook

@Suite("CBButton")
struct CBButtonTests {

    // MARK: - Configuration defaults

    @Test("Default configuration matches primary / medium / rounded / no icon")
    func configurationDefaults() {
        let config = CBButton.Configuration()
        #expect(config.style == .primary)
        #expect(config.size == .medium)
        #expect(config.shape == .rounded)
        #expect(config.icon == .none)
        #expect(config.fullWidth == false)
        #expect(config.isLoading == false)
        #expect(config.accessibilityLabel == nil)
        #expect(config.accessibilityHint == nil)
    }

    // MARK: - Size metrics

    @Test("Each size returns metrics with the documented height", arguments: [
        (CBButton.Size.small, CGFloat(32)),
        (CBButton.Size.medium, CGFloat(44)),
        (CBButton.Size.large, CGFloat(56))
    ])
    func sizeMetricsHeights(size: CBButton.Size, expectedHeight: CGFloat) {
        #expect(size.metrics.height == expectedHeight)
    }

    @Test("Horizontal padding and corner radius grow monotonically with size")
    func sizeMetricsAreMonotonic() {
        let small = CBButton.Size.small.metrics
        let medium = CBButton.Size.medium.metrics
        let large = CBButton.Size.large.metrics
        #expect(small.horizontalPadding < medium.horizontalPadding)
        #expect(medium.horizontalPadding < large.horizontalPadding)
        #expect(small.cornerRadius < medium.cornerRadius)
        #expect(medium.cornerRadius < large.cornerRadius)
    }

    @Test("Medium and large meet Apple's 44pt minimum touch target")
    func mediumAndLargeMeetMinimumTouchTarget() {
        let appleMinimum: CGFloat = 44
        #expect(CBButton.Size.medium.metrics.height >= appleMinimum)
        #expect(CBButton.Size.large.metrics.height >= appleMinimum)
    }

    // MARK: - Style palettes

    @Test("Outline is the only style with a non-zero border width")
    func onlyOutlineHasBorder() {
        for style in CBButton.Style.allCases {
            let width = style.palette(pressed: false).borderWidth
            if style == .outline {
                #expect(width > 0)
            } else {
                #expect(width == 0)
            }
        }
    }

    @Test("Primary background dims when pressed")
    func primaryPressedDimsBackground() {
        let resting = CBButton.Style.primary.palette(pressed: false)
        let pressed = CBButton.Style.primary.palette(pressed: true)
        #expect(resting.background != pressed.background)
    }

    @Test("Destructive background dims when pressed")
    func destructivePressedDimsBackground() {
        let resting = CBButton.Style.destructive.palette(pressed: false)
        let pressed = CBButton.Style.destructive.palette(pressed: true)
        #expect(resting.background != pressed.background)
    }

    @Test("Filled styles use white foreground for contrast", arguments: [
        CBButton.Style.primary,
        CBButton.Style.destructive
    ])
    func filledStylesUseWhiteForeground(style: CBButton.Style) {
        #expect(style.palette(pressed: false).foreground == .white)
    }

    @Test("Tinted styles use the accent foreground", arguments: [
        CBButton.Style.secondary,
        CBButton.Style.tertiary,
        CBButton.Style.outline
    ])
    func tintedStylesUseAccentForeground(style: CBButton.Style) {
        #expect(style.palette(pressed: false).foreground == .accentColor)
    }

    @Test("Ghost style adopts the system label color so dark mode reads correctly")
    func ghostUsesPrimaryForeground() {
        #expect(CBButton.Style.ghost.palette(pressed: false).foreground == .primary)
    }

    // MARK: - Icon enum

    @Test("Icon.none and Icon.only carry the documented payload semantics")
    func iconPayloadSemantics() {
        let none: CBButton.Icon = .none
        let only: CBButton.Icon = .only(systemName: "heart.fill")
        #expect(none == .none)
        if case .only(let symbol) = only {
            #expect(symbol == "heart.fill")
        } else {
            Issue.record("expected .only case")
        }
    }
}
