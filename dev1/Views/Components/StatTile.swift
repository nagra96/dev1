//
//  StatTile.swift
//  dev1
//

import SwiftUI

/// A single headline number. Used in a KPI row rather than plotting one-value
/// bars — when the data is one current value, the number *is* the chart.
struct StatTile: View {
    let label: String
    let value: String
    var systemImage: String?
    var tint: Color = Theme.accent
    var caption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.sm) {
            HStack(spacing: Theme.Space.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(tint)
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.inkSecondary)
            }

            // Proportional (not tabular) figures: these are standalone display
            // numbers, not a vertically aligned column.
            Text(value)
                .font(Theme.figure(24, weight: .bold))
                .foregroundStyle(Theme.inkPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            if let caption {
                Text(caption)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.inkMuted)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: Theme.Space.lg)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(caption.map { "\(value), \($0)" } ?? value)
    }
}

/// A single ratio against a limit. The filled portion carries the accent; the
/// unfilled track is a lighter step of the same hue, so state reads across the
/// whole bar rather than only where the fill ends.
struct ProgressMeter: View {
    let fraction: Double
    var height: CGFloat = 10
    var tint: Color = Theme.accent

    private var clamped: Double {
        min(max(fraction.isFinite ? fraction : 0, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.accentMuted)
                Capsule()
                    .fill(tint)
                    .frame(width: max(geo.size.width * clamped, clamped > 0 ? height : 0))
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityValue("\(Int(clamped * 100)) percent")
    }
}

/// Monogram avatar. Gives roster rows a visual anchor instead of a wall of
/// left-aligned text. The hue is derived from the name so it stays stable for a
/// given family, and it is decorative only — never the sole carrier of meaning.
struct Avatar: View {
    let name: String
    var size: CGFloat = 40

    private var initials: String {
        let parts = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .prefix(2)
        let letters = parts.compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    /// Deterministic hue from the name, kept in a narrow band around the brand
    /// so the roster reads as one family of colors rather than confetti.
    private var background: Color {
        let hash = name.unicodeScalars.reduce(UInt32(7)) { ($0 &* 31) &+ $1.value }
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.32, brightness: 0.62)
    }

    var body: some View {
        Circle()
            .fill(background)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(Theme.figure(size * 0.38, weight: .bold))
                    .foregroundStyle(.white)
            )
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatTile(label: "Collected", value: "$525", systemImage: "arrow.down.circle.fill", tint: Theme.statusGood)
                StatTile(label: "Expenses", value: "$1,000", systemImage: "arrow.up.circle.fill", tint: Theme.statusCritical)
            }
            ProgressMeter(fraction: 0.58).padding(.horizontal)
            HStack { Avatar(name: "Maria Chen"); Avatar(name: "David Ortiz") }
        }
        .padding()
    }
    .background(Theme.plane)
}
