//
//  Theme.swift
//  dev1
//

import SwiftUI
import UIKit

/// The app's design tokens.
///
/// Colors are declared as light/dark pairs and resolved by `UIColor`'s trait
/// closure, so a single `Color` adapts to the active appearance without any
/// view needing to read `@Environment(\.colorScheme)`.
///
/// The brand and status values are not arbitrary — they were checked against
/// the data-visualization gates (OKLCH lightness band, chroma floor, WCAG
/// contrast vs. the surface they render on, and OKLab CVD separation). Two
/// results shape the UI and must not be undone by a later "just use a colored
/// dot" simplification:
///
/// 1. Status green and status red are only ΔE 4.1 apart under deuteranopia,
///    far below the ≥8 target. Paid vs. unpaid is precisely the distinction a
///    colorblind treasurer has to make, so `StatusBadge` always pairs the color
///    with an icon *and* a text label.
/// 2. Amber measures 1.83:1 on the light surface, under the 3:1 bar. Same
///    mitigation: the label carries the meaning, the color only reinforces it.
enum Theme {

    // MARK: - Brand

    /// Primary brand hue. Indigo deliberately sits clear of the green/amber/red
    /// status family so a brand-colored mark can never be misread as a payment
    /// state.
    static let accent = dynamic(light: 0x4F46E5, dark: 0x7C7AEE)

    /// Recessive companion to `accent`, used for meter tracks and tinted
    /// icon wells — the "unfilled" plane, never a data value.
    static let accentMuted = dynamic(light: 0xE0E7FF, dark: 0x2E2E45)

    // MARK: - Surfaces

    /// Card surface. Content sits on this.
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x1C1C1E)

    /// The plane behind the cards.
    static let plane = dynamic(light: 0xF2F2F7, dark: 0x000000)

    /// Hairline ring around cards and dividers.
    static let hairline = dynamic(light: 0xE5E5EA, dark: 0x2C2C2E)

    // MARK: - Ink

    static let inkPrimary = dynamic(light: 0x0B0B0B, dark: 0xFFFFFF)
    static let inkSecondary = dynamic(light: 0x52514E, dark: 0xC3C2B7)
    static let inkMuted = dynamic(light: 0x898781, dark: 0x898781)

    // MARK: - Status (reserved — never reused as a decorative or brand color)

    static let statusGood = dynamic(light: 0x0CA30C, dark: 0x0CA30C)
    static let statusWarning = dynamic(light: 0xFAB219, dark: 0xFAB219)
    static let statusCritical = dynamic(light: 0xD03B3B, dark: 0xE66767)

    // MARK: - Spacing

    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
    }

    enum Radius {
        static let card: CGFloat = 18
        static let control: CGFloat = 12
        static let mark: CGFloat = 4
    }

    // MARK: - Type

    /// Money and other standalone figures use rounded proportional digits.
    /// `tabular` is reserved for columns that must align vertically.
    static func figure(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // MARK: - Helpers

    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Card

struct CardModifier: ViewModifier {
    var padding: CGFloat = Theme.Space.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func card(padding: CGFloat = Theme.Space.lg) -> some View {
        modifier(CardModifier(padding: padding))
    }
}
