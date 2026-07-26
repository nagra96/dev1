//
//  OnboardingView.swift
//  dev1
//

import SwiftUI
import SwiftData

/// First-run setup. Besides collecting the team details that appear on the
/// board report, this is where the user chooses whether to start with sample
/// data — previously the app silently seeded itself, which left a new user
/// unsure which numbers were theirs and which were fake.
struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @AppStorage(PreferenceKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    @State private var step = 0
    @State private var teamName = ""
    @State private var organization = ""
    @State private var sport = "Soccer"
    @State private var seasonName = ""
    @State private var treasurerName = ""
    @State private var treasurerEmail = ""
    @State private var loadSampleData = false

    private var trimmedTeamName: String {
        teamName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            Theme.plane.ignoresSafeArea()

            VStack(spacing: 0) {
                switch step {
                case 0: welcomeStep
                case 1: teamStep
                default: treasurerStep
                }
            }
        }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: Theme.Space.xl) {
            Spacer()

            Image(systemName: "chart.pie.fill")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 108, height: 108)
                .background(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accent.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
                .shadow(color: Theme.accent.opacity(0.3), radius: 18, y: 8)

            VStack(spacing: Theme.Space.md) {
                Text("TeamTreasury")
                    .font(Theme.figure(32, weight: .bold))
                    .foregroundStyle(Theme.inkPrimary)
                Text("Collect team fees, track the season budget, and hand the board a clean report \u{2014} without chasing anyone over Venmo.")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Space.xl)
            }

            VStack(spacing: Theme.Space.md) {
                FeatureLine(icon: "dollarsign.circle.fill", text: "Fee campaigns with automatic reminders")
                FeatureLine(icon: "person.2.fill", text: "A running balance for every family")
                FeatureLine(icon: "receipt.fill", text: "Expenses with receipt photos")
            }
            .padding(.horizontal, Theme.Space.xl)

            Spacer()

            primaryButton("Get Started") { withAnimation { step = 1 } }
                .padding(.horizontal, Theme.Space.xl)
                .padding(.bottom, Theme.Space.xl)
        }
    }

    private var teamStep: some View {
        stepScaffold(
            title: "Your team",
            subtitle: "This appears on the season report you share with the club board.",
            canContinue: !trimmedTeamName.isEmpty,
            continueTitle: "Continue",
            onContinue: { withAnimation { step = 2 } }
        ) {
            VStack(spacing: Theme.Space.lg) {
                LabeledField(title: "Team name", text: $teamName, placeholder: "Riverside U12 Rovers")
                LabeledField(title: "Club or organization", text: $organization, placeholder: "Riverside Youth Soccer", optional: true)

                VStack(alignment: .leading, spacing: Theme.Space.sm) {
                    Text("Sport")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.inkSecondary)
                    Picker("Sport", selection: $sport) {
                        ForEach(TeamProfile.sports, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Space.md)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
                }

                LabeledField(title: "Season", text: $seasonName, placeholder: "Spring 2026", optional: true)
            }
        }
    }

    private var treasurerStep: some View {
        stepScaffold(
            title: "You, the treasurer",
            subtitle: "Used to sign the report. Everything stays on this device.",
            canContinue: true,
            continueTitle: "Start Using TeamTreasury",
            onContinue: finish
        ) {
            VStack(spacing: Theme.Space.lg) {
                LabeledField(title: "Your name", text: $treasurerName, placeholder: "Alex Morgan", optional: true)
                LabeledField(title: "Your email", text: $treasurerEmail, placeholder: "alex@example.com", optional: true, keyboard: .emailAddress)

                Toggle(isOn: $loadSampleData) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Load sample data")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.inkPrimary)
                        Text("Four example families and two fee campaigns, so you can look around before adding real people. You can erase it any time in Settings.")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
                .tint(Theme.accent)
                .padding(Theme.Space.md)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
            }
        }
    }

    // MARK: - Scaffold

    @ViewBuilder
    private func stepScaffold<Content: View>(
        title: String,
        subtitle: String,
        canContinue: Bool,
        continueTitle: String,
        onContinue: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    VStack(alignment: .leading, spacing: Theme.Space.sm) {
                        Text(title)
                            .font(Theme.figure(28, weight: .bold))
                            .foregroundStyle(Theme.inkPrimary)
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.inkSecondary)
                    }
                    content()
                }
                .padding(Theme.Space.xl)
            }

            primaryButton(continueTitle, enabled: canContinue, action: onContinue)
                .padding(.horizontal, Theme.Space.xl)
                .padding(.bottom, Theme.Space.xl)
        }
    }

    private func primaryButton(_ title: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Space.lg)
                .background(enabled ? Theme.accent : Theme.inkMuted.opacity(0.35),
                            in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    // MARK: - Finish

    private func finish() {
        let profile = TeamProfile(
            teamName: trimmedTeamName,
            organization: organization.trimmingCharacters(in: .whitespacesAndNewlines),
            sport: sport,
            seasonName: seasonName.trimmingCharacters(in: .whitespacesAndNewlines),
            treasurerName: treasurerName.trimmingCharacters(in: .whitespacesAndNewlines),
            treasurerEmail: treasurerEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(profile)

        if loadSampleData {
            SeedData.loadSample(context: context)
        }

        try? context.save()
        hasCompletedOnboarding = true
    }
}

// MARK: - Small pieces

private struct FeatureLine: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Space.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 30, height: 30)
                .background(Theme.accentMuted, in: Circle())
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Theme.inkSecondary)
            Spacer(minLength: 0)
        }
    }
}

struct LabeledField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var optional: Bool = false
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.sm) {
            HStack(spacing: Theme.Space.xs) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.inkSecondary)
                if optional {
                    Text("Optional")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled(keyboard == .emailAddress)
                .font(.system(size: 16))
                .padding(Theme.Space.md)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
