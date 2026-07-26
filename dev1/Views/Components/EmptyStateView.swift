//
//  EmptyStateView.swift
//  dev1
//

import SwiftUI

/// Empty states are the first thing a new treasurer sees, so they get real
/// styling and a way forward rather than a gray sentence.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Space.md) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 76, height: 76)
                .background(Theme.accentMuted, in: Circle())

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.inkPrimary)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Space.xl)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, Theme.Space.xl)
                        .padding(.vertical, Theme.Space.md)
                        .background(Theme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, Theme.Space.xs)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Space.xl)
    }
}

#Preview {
    EmptyStateView(
        icon: "dollarsign.circle.fill",
        title: "No fee campaigns",
        message: "Create a campaign to start collecting from your roster.",
        actionTitle: "New Campaign"
    ) {}
    .background(Theme.plane)
}
