//
//  AboutView.swift
//  dev1
//

import SwiftUI

struct AboutView: View {
    private var version: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Space.lg) {
                VStack(spacing: Theme.Space.md) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 76, height: 76)
                        .background(
                            LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.75)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    Text("TeamTreasury")
                        .font(Theme.figure(22, weight: .bold))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Version \(version)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity)
                .card(padding: Theme.Space.xl)

                // Being explicit about this in-product, not just in the repo
                // docs. Someone evaluating the app should not have to read
                // source to learn that the payment flow is a simulation.
                VStack(alignment: .leading, spacing: Theme.Space.md) {
                    Label("What\u{2019}s real, what isn\u{2019}t", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.statusWarning)

                    capabilityRow(true, "Fee campaigns, balances, expenses, and the season report are fully working.")
                    capabilityRow(false, "Card and ACH collection is simulated. No card is charged and no money moves.")
                    capabilityRow(false, "Reminders only stamp a date locally \u{2014} no email or text is sent.")
                    capabilityRow(false, "There is no account or cloud sync. Data lives on this device only, with no backup.")

                    Text("Making payments and reminders real requires a hosted backend with Stripe Connect. See docs/DEPLOYMENT.md in the project repository.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                        .padding(.top, Theme.Space.xs)
                }
                .card()

                VStack(alignment: .leading, spacing: Theme.Space.sm) {
                    Text("Privacy")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("TeamTreasury collects nothing and sends nothing anywhere. There is no analytics, no tracking, and no network connection. Everything you enter stays in the app\u{2019}s own storage on this device.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.inkSecondary)
                }
                .card()
            }
            .padding(Theme.Space.lg)
        }
        .background(Theme.plane)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func capabilityRow(_ works: Bool, _ text: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Space.sm) {
            Image(systemName: works ? "checkmark.circle.fill" : "circle.slash")
                .font(.system(size: 13))
                .foregroundStyle(works ? Theme.statusGood : Theme.inkMuted)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.inkSecondary)
        }
    }
}

#Preview {
    NavigationStack { AboutView() }
}
