//
//  StatusBadge.swift
//  dev1
//

import SwiftUI

/// A payment-state badge.
///
/// The icon and the text are load-bearing, not decoration. Status green and
/// status red measure ΔE 4.1 apart under deuteranopia — well below the ≥8
/// separation target — so "paid" and "unpaid" are indistinguishable by hue for
/// a red-green colorblind reader. The glyph and the word carry the meaning;
/// the color only reinforces it. Do not reduce this to a bare colored dot.
struct StatusBadge: View {
    let status: PaymentStatus
    var compact: Bool = false

    private var label: String {
        switch status {
        case .paid: return "Paid"
        case .partial: return "Partial"
        case .unpaid: return "Unpaid"
        }
    }

    private var icon: String {
        switch status {
        case .paid: return "checkmark.circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .unpaid: return "exclamationmark.circle.fill"
        }
    }

    private var tint: Color {
        switch status {
        case .paid: return Theme.statusGood
        case .partial: return Theme.statusWarning
        case .unpaid: return Theme.statusCritical
        }
    }

    var body: some View {
        HStack(spacing: Theme.Space.xs) {
            Image(systemName: icon)
                .font(.system(size: compact ? 10 : 11, weight: .semibold))
            Text(label)
                .font(.system(size: compact ? 11 : 12, weight: .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, compact ? 7 : 9)
        .padding(.vertical, compact ? 3 : 5)
        .background(tint.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}

/// A neutral counterpart for non-status metadata (counts, due dates), kept
/// visually distinct from `StatusBadge` so state and metadata never blur.
struct MetaBadge: View {
    let text: String
    var systemImage: String?
    var tint: Color = Theme.inkSecondary

    var body: some View {
        HStack(spacing: Theme.Space.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(tint.opacity(0.10), in: Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadge(status: .paid)
        StatusBadge(status: .partial)
        StatusBadge(status: .unpaid)
        MetaBadge(text: "Due Mar 1", systemImage: "calendar")
    }
    .padding()
    .background(Theme.plane)
}
