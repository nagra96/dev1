//
//  SettingsView.swift
//  dev1
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppLock.self) private var appLock

    @Query private var profiles: [TeamProfile]
    @Query private var families: [FamilyMember]
    @Query private var campaigns: [FeeCampaign]
    @Query private var expenses: [Expense]

    @AppStorage(PreferenceKey.passFeeToFamilyDefault) private var passFeeDefault = true
    @AppStorage(PreferenceKey.reminderLeadDays) private var reminderLeadDays = 3

    @State private var isPresentingEditProfile = false
    @State private var isConfirmingErase = false
    @State private var isPresentingSampleConfirm = false
    @State private var exportURL: URL?
    @State private var toast: String?

    private var profile: TeamProfile? { profiles.first }

    var body: some View {
        List {
            teamSection
            accountSection
            securitySection
            defaultsSection
            dataSection
            aboutSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.plane)
        .navigationTitle("Settings")
        .sheet(isPresented: $isPresentingEditProfile) {
            if let profile {
                TeamProfileEditor(profile: profile)
            }
        }
        .confirmationDialog(
            "Erase all data?",
            isPresented: $isConfirmingErase,
            titleVisibility: .visible
        ) {
            Button("Erase Everything", role: .destructive) { erase() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes every family, campaign, payment record, and expense on this device. Export first if you want a copy \u{2014} this cannot be undone.")
        }
        .confirmationDialog(
            "Load sample data?",
            isPresented: $isPresentingSampleConfirm,
            titleVisibility: .visible
        ) {
            Button("Add Sample Data") {
                SeedData.loadSample(context: context)
                show("Sample data added")
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Adds four example families and two campaigns alongside your existing records.")
        }
        .overlay(alignment: .bottom) {
            if let toast {
                Label(toast, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Space.lg)
                    .padding(.vertical, Theme.Space.md)
                    .background(Theme.inkPrimary.opacity(0.92), in: Capsule())
                    .padding(.bottom, Theme.Space.xxl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Sections

    private var teamSection: some View {
        Section {
            Button {
                isPresentingEditProfile = true
            } label: {
                HStack(spacing: Theme.Space.md) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(
                            LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.75)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile?.displayTitle ?? "My Team")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.inkPrimary)
                        let subtitle = profile?.displaySubtitle ?? ""
                        Text(subtitle.isEmpty ? (profile?.sport ?? "Team") : subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } header: {
            Text("Team")
        }
    }

    private var accountSection: some View {
        Section {
            HStack(spacing: Theme.Space.md) {
                Avatar(name: profile?.treasurerName.isEmpty == false ? profile!.treasurerName : "Treasurer", size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile?.treasurerName.isEmpty == false ? profile!.treasurerName : "Treasurer")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.inkPrimary)
                    Text(profile?.treasurerEmail.isEmpty == false ? profile!.treasurerEmail : "No email set")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMuted)
                }
                Spacer()
                MetaBadge(text: "This device", systemImage: "iphone", tint: Theme.inkSecondary)
            }
            .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: Theme.Space.sm) {
                Label("Cloud sync isn\u{2019}t available yet", systemImage: "icloud.slash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.inkPrimary)
                Text("Your records live only on this phone. There is no account to sign into and no backup \u{2014} multi-device access needs the hosted backend described in the project docs. Until then, use Export below to keep a copy.")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.inkSecondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Account")
        }
    }

    private var securitySection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { appLock.isEnabled },
                set: { appLock.isEnabled = $0 }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Require \(appLock.biometryDescription)")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Locks the app when you leave it.")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .tint(Theme.accent)
            .disabled(!appLock.isAvailable)

            if !appLock.isAvailable {
                Label("Set a device passcode to use App Lock.", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.statusWarning)
            }
        } header: {
            Text("Security")
        }
    }

    private var defaultsSection: some View {
        Section {
            Toggle(isOn: $passFeeDefault) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pass processing fee to families")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Preselected when collecting a payment.")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .tint(Theme.accent)

            Stepper(value: $reminderLeadDays, in: 0...21) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remind \(reminderLeadDays) \(reminderLeadDays == 1 ? "day" : "days") before due")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Used to flag campaigns coming due.")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
        } header: {
            Text("Defaults")
        }
    }

    private var dataSection: some View {
        Section {
            exportRow("Family balances", systemImage: "person.2.fill") {
                DataExport.balancesCSV(families: families)
            }
            exportRow("Payments", systemImage: "dollarsign.circle.fill") {
                DataExport.paymentsCSV(campaigns: campaigns)
            }
            exportRow("Expenses", systemImage: "receipt.fill") {
                DataExport.expensesCSV(expenses: expenses)
            }

            Button {
                isPresentingSampleConfirm = true
            } label: {
                Label("Load sample data", systemImage: "wand.and.stars")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.inkPrimary)
            }

            Button(role: .destructive) {
                isConfirmingErase = true
            } label: {
                Label("Erase all data", systemImage: "trash.fill")
                    .font(.system(size: 15))
            }
        } header: {
            Text("Data")
        } footer: {
            Text("\(families.count) families \u{00B7} \(campaigns.count) campaigns \u{00B7} \(expenses.count) expenses")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Label("About TeamTreasury", systemImage: "info.circle")
                    .font(.system(size: 15))
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func exportRow(_ title: String, systemImage: String, csv: @escaping () -> String) -> some View {
        if let url = DataExport.writeTemporaryFile(named: title, contents: csv()) {
            ShareLink(item: url) {
                Label("Export \(title.lowercased())", systemImage: systemImage)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.inkPrimary)
            }
        } else {
            Label("Export \(title.lowercased()) unavailable", systemImage: "exclamationmark.triangle")
                .font(.system(size: 15))
                .foregroundStyle(Theme.inkMuted)
        }
    }

    private func erase() {
        if DataReset.eraseAll(context: context) {
            show("All data erased")
        } else {
            show("Couldn\u{2019}t erase data")
        }
    }

    private func show(_ message: String) {
        withAnimation { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { toast = nil }
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environment(AppLock())
        .modelContainer(for: [TeamProfile.self, FamilyMember.self, FeeCampaign.self, Payment.self, Expense.self], inMemory: true)
}
