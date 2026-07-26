//
//  LockScreenView.swift
//  dev1
//

import SwiftUI

struct LockScreenView: View {
    let appLock: AppLock

    var body: some View {
        ZStack {
            Theme.plane.ignoresSafeArea()

            VStack(spacing: Theme.Space.xl) {
                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 88, height: 88)
                    .background(Theme.accentMuted, in: Circle())

                VStack(spacing: Theme.Space.sm) {
                    Text("TeamTreasury is locked")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Unlock with \(appLock.biometryDescription) to view your team\u{2019}s finances.")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Space.xl)
                }

                if let error = appLock.lastError {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.statusCritical)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Space.xl)
                }

                Spacer()

                Button {
                    Task { await appLock.unlock() }
                } label: {
                    Label("Unlock", systemImage: "faceid")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Space.lg)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.Space.xl)
                .padding(.bottom, Theme.Space.xl)
            }
        }
        .task {
            // Prompt immediately so the user isn't made to tap a button first.
            await appLock.unlock()
        }
    }
}
