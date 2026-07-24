# Deployment

This document is deliberately blunt about the gap between "builds and runs
as a demo" and "ready to handle a real team's money." Read the first
section before promising anyone a launch date.

## What's real vs. simulated today

| Feature | State |
|---|---|
| Fee campaigns, ledger, expense tracking, season report | Real. Local SwiftData storage, works fully offline. |
| Reminders | **UI-only.** `Payment.reminderSentDate` is stamped locally; no email/SMS/push is sent. |
| Card/ACH collection | **Simulated.** `CollectPaymentView` computes a realistic fee and marks the payment paid after a fake delay. No payment processor is integrated and no money moves. |
| Multi-device / multi-user sync | **Not implemented.** Each install has its own local store. |

Everything below assumes you're taking this from "convincing local demo" to
"real product." None of it is optional if the app is going to touch real
money — skipping it isn't a shortcut, it's a different, riskier product.

## 1. App Store submission checklist (for the demo/TestFlight as-is)

These apply even before real payments are wired up, if you want to get the
current build in front of testers via TestFlight:

- [ ] **Bundle identifier**: `PRODUCT_BUNDLE_IDENTIFIER` is currently
      `dato.com.karan.dev1` — a scaffold placeholder. Change it to a
      reverse-DNS identifier under a domain you control (e.g.
      `com.teamtreasury.app`) in both the `dev1` and `dev1Tests` build
      settings before you register it in App Store Connect; you cannot
      rename it later without losing your App Store listing.
- [ ] **Apple Developer Program** enrollment and a real Team ID (the
      project currently references team `S8UMS5TQ89`, which was the
      scaffold's default — replace with your own team in Signing &
      Capabilities).
- [ ] **App icon**: `Assets.xcassets/AppIcon.appiconset` has no image yet,
      only the modern single-1024×1024 slot. This needs real brand design
      before submission — don't ship a placeholder icon to the App Store.
- [ ] **Screenshots** for App Store Connect (6.9", 6.5" iPhone at minimum;
      iPad if you keep `TARGETED_DEVICE_FAMILY = "1,2"`).
- [ ] **Privacy nutrition label** in App Store Connect should match
      `dev1/PrivacyInfo.xcprivacy`, which currently declares no tracking and
      no data collection — accurate for the current build, but **you must
      update both** the moment you add analytics, crash reporting, or the
      real Stripe SDK (Stripe's own SDK ships its own privacy manifest
      declaring the required-reason APIs it uses; your merged manifest and
      your App Store Connect answers need to stay in sync with it).
- [ ] Support URL, marketing URL, age rating, and the rest of the standard
      App Store Connect listing fields.
- [ ] Decide your versioning scheme early: `MARKETING_VERSION` (user-facing,
      e.g. `1.0`) and `CURRENT_PROJECT_VERSION` (build number, must
      increase on every TestFlight/App Store upload) are both currently
      `1`.

## 2. Real payment collection (the actual product)

`CollectPaymentView` is a UI mock. Turning it into the real thing:

1. **Never create a Stripe PaymentIntent client-side.** Doing so requires
   your Stripe *secret* key, which must never ship inside the app binary.
   You need a backend — even a minimal one — whose only job at first can be
   "authenticated request in, PaymentIntent out."
2. **Use Stripe's iOS SDK (`PaymentSheet`)** on the client instead of a
   hand-rolled card form. It's what makes you PCI-compliant without a PCI
   audit: raw card data goes straight from the SDK to Stripe and never
   touches your server or this app's code.
3. **Use Stripe Connect**, not a plain Stripe account, given the product's
   pricing model (a 2% platform fee, or a flat $99/season, per the product
   spec). Connect is built for exactly this "marketplace collects on behalf
   of many independent teams" shape — each team gets its own connected
   account, and your platform fee is taken automatically via
   `application_fee_amount` on each charge. Without Connect, you'd be
   acting as a money transmitter yourself, which is a materially different
   (and much heavier) regulatory situation.
4. **Treat your backend's payment records as the source of truth**, not
   this app's local SwiftData store. The client should reflect
   webhook-confirmed state (`payment_intent.succeeded`, etc.), not mark a
   `Payment` as paid just because the client-side call returned — a flaky
   connection shouldn't be able to desync "the app thinks it's paid" from
   "Stripe actually captured the money."
5. Card and ACH have different settlement and fee timing (ACH commonly
   takes days and can fail well after the UI says "success"); the current
   `FeeCalculator` rates are correct as *display estimates* but the backend
   should be the one computing and reconciling actual fees charged.

## 3. Real reminders

"Automatic reminders to non-payers" (per the product spec) can't be a
client-only feature — an iPhone that's closed can't send an email at 9am on
the due date. This needs:

- A backend job (cron/scheduled function) that queries overdue `Payment`
  rows and sends email/SMS via a provider (SendGrid, Postmark, Twilio) or
  push via APNs.
- That in turn means payments/campaigns need to live server-side, not just
  in each device's local SwiftData store — which is the same requirement as
  the sync section below.

## 4. Sync and multi-user access

Right now, a club treasurer's phone and a club board member's phone would
have two completely independent local databases. A real deployment needs
one of:

- **A hosted backend** (recommended, given money is involved): the app
  talks to an API backed by a real database; SwiftData becomes a local
  cache/offline buffer rather than the source of truth. This is also a
  prerequisite for the reminder system above and for any web-based
  "board view" of the season report.
- **CloudKit** (private + shared databases) as a lighter-weight option if
  you're willing to stay Apple-only (no Android, no web board view) and
  are comfortable with CloudKit's sharing model for "treasurer + a few
  board members see the same season's data." Given the payments and
  compliance requirements above already push you toward a backend, CloudKit
  alone probably doesn't save enough to be worth the platform lock-in.

## 5. CI/CD

`.github/workflows/ios.yml` builds and runs `dev1Tests` on every push and
PR against a macOS GitHub Actions runner, targeting an iPhone 16 simulator
with code signing disabled (simulator builds don't need it). For automated
TestFlight delivery on top of that, add a release job using
[Fastlane](https://fastlane.tools) (`fastlane pilot upload`) or
[Xcode Cloud](https://developer.apple.com/xcode-cloud/) — neither is set up
yet.

## 6. Data migration

The SwiftData schema (`FamilyMember`, `FeeCampaign`, `Payment`, `Expense`)
has no versioning concerns yet because there are no real users with data on
disk. The moment this ships to real devices, any future field
addition/removal needs a
[SwiftData migration plan](https://developer.apple.com/documentation/swiftdata/versionedschema) —
plan for that before the first non-seed data hits a real user's phone,
not after.
