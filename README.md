# TeamTreasury

An iOS app that gives volunteer youth-sports treasurers a real workflow for
collecting fees, tracking a season budget, and reporting to the club board —
instead of Venmo screenshots and a spreadsheet.

This repository contains the client app (SwiftUI + SwiftData). It's a
working MVP you can build and run today; see
[`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) for exactly what's real versus
simulated, and what's needed before this could take real money in
production.

## Features

- **Fee campaigns** — create a campaign (e.g. "Uniform Fee, $150, due March
  1"), which fans out a balance to every family on the roster, with
  per-family and bulk reminders for anyone who hasn't paid.
- **Per-family ledger** — every family's paid/owed balance and full fee
  history in one place.
- **Expense tracking** — log expenses by category with an optional receipt
  photo, plus a season budget view grouped by category.
- **Card/ACH collection** — a guided checkout flow with a processing-fee
  pass-through toggle. **This currently simulates the charge** rather than
  moving real money; see [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) for the
  Stripe integration plan.
- **One-tap season report** — collected/expected/expenses/net plus
  per-family balances, shareable as text via the share sheet.

## Requirements

- Xcode 16.4 or later
- iOS 18.5+ deployment target (matches the project's `IPHONEOS_DEPLOYMENT_TARGET`)
- No third-party dependencies — the app only links Apple frameworks
  (SwiftUI, SwiftData, PhotosUI, os)

## Getting Started

```bash
git clone <this-repo>
cd dev1
open dev1.xcodeproj
```

Select the **dev1** scheme, choose an iPhone simulator, and hit Run
(`Cmd+R`). The app seeds itself with sample families, two fee campaigns, and
a few expenses on first launch so there's something to look at immediately.

## Running Tests

The `dev1Tests` target uses [Swift Testing](https://developer.apple.com/documentation/testing)
and covers the model layer (`FamilyMember`, `FeeCampaign`, `Payment`) and the
pure business logic in `FeeCalculator` and `CurrencyInput`.

- In Xcode: `Cmd+U`, or open the Test navigator and run individual suites.
- From the command line:

  ```bash
  xcodebuild test \
    -project dev1.xcodeproj \
    -scheme dev1 \
    -destination "platform=iOS Simulator,name=iPhone 16"
  ```

CI runs the same command on every push and pull request — see
[`.github/workflows/ios.yml`](.github/workflows/ios.yml).

## Project Structure

```
dev1/
├── dev1App.swift              # App entry point, ModelContainer setup, seeding
├── PrivacyInfo.xcprivacy      # App Store privacy manifest
├── Models/                    # SwiftData @Model types
│   ├── FamilyMember.swift
│   ├── FeeCampaign.swift
│   ├── Payment.swift
│   └── Expense.swift
├── Support/                   # Pure logic + small utilities, unit-testable
│   ├── FeeCalculator.swift    # Stripe-style processing-fee math
│   ├── CurrencyInput.swift    # Locale-aware amount parsing/validation
│   ├── Decimal+Currency.swift
│   └── SeedData.swift
└── Views/
    ├── RootTabView.swift       # Tab bar: Dashboard / Campaigns / Families / Expenses
    ├── DashboardView.swift     # Season snapshot + collection progress
    ├── CampaignsListView.swift, NewCampaignView.swift, CampaignDetailView.swift
    ├── FamiliesListView.swift, NewFamilyView.swift, FamilyDetailView.swift
    ├── ExpensesListView.swift, NewExpenseView.swift
    ├── CollectPaymentView.swift  # Simulated Stripe-style checkout
    ├── SeasonReportView.swift    # Shareable board report
    └── Components/                # Shared row views

dev1Tests/                     # Swift Testing unit tests
docs/
├── ARCHITECTURE.md
└── DEPLOYMENT.md
```

More on how the pieces fit together: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Status & Ownership

This is a product in development, not an open-source project — there's no
license file, and the code isn't available for reuse. See
[`CHANGELOG.md`](CHANGELOG.md) for what's shipped so far.
