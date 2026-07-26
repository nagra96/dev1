//
//  AppLock.swift
//  dev1
//

import Foundation
import LocalAuthentication
import SwiftUI
import os

/// Biometric / passcode gate for the app.
///
/// This is the app's real security boundary today, and it is deliberately
/// *device-local*. There is no account server, so there is nothing to
/// authenticate against remotely — what actually protects a treasurer's ledger
/// on a lost or shared phone is the device owner check, which is exactly what
/// `LAPolicy.deviceOwnerAuthentication` performs.
///
/// `.deviceOwnerAuthentication` (rather than `.deviceOwnerAuthenticationWithBiometrics`)
/// is intentional: it falls back to the device passcode when Face ID is
/// unavailable, unenrolled, or locked out, so enabling the lock can never
/// strand someone outside their own books.
@Observable
final class AppLock {
    /// True when the app should be showing the lock screen.
    private(set) var isLocked: Bool = false
    private(set) var lastError: String?

    private let logger = Logger(subsystem: "com.teamtreasury.dev1", category: "AppLock")

    /// Whether the user has switched the lock on in Settings.
    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.enabledKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.enabledKey)
            if !newValue { isLocked = false }
        }
    }

    private static let enabledKey = "appLockEnabled"

    /// What the device can actually offer, so Settings can label the toggle
    /// honestly instead of promising "Face ID" on a device without it.
    var biometryDescription: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return "Device passcode not set"
        }
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Device passcode"
        }
    }

    var isAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    /// Lock on backgrounding, so the ledger isn't sitting open in the app
    /// switcher.
    func lockIfEnabled() {
        if isEnabled { isLocked = true }
    }

    func unlock() async {
        guard isEnabled else {
            isLocked = false
            return
        }

        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // The device can't evaluate the policy at all (no passcode set).
            // Failing open here is the right call: the alternative permanently
            // locks someone out of their own local data with no recovery path.
            logger.error("App lock unavailable: \(error?.localizedDescription ?? "unknown")")
            lastError = "Device authentication isn\u{2019}t available. App Lock has been turned off."
            isEnabled = false
            isLocked = false
            return
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock TeamTreasury to view your team\u{2019}s finances"
            )
            if success {
                isLocked = false
                lastError = nil
            }
        } catch {
            logger.notice("Unlock attempt failed: \(error.localizedDescription)")
            lastError = "Authentication failed. Try again."
        }
    }
}
