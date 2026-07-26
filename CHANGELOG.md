# Changelog

All notable changes to this project are documented in this file. Format
loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added — app fundamentals
- **Onboarding flow.** First launch now collects team, club, sport, season, and
  treasurer details (`TeamProfile`) instead of dropping the user into an app
  full of unexplained data. Sample data is opt-in from this screen and can be
  loaded or erased later from Settings — previously the app silently seeded
  itself, which in a financial app makes it impossible to tell which balances
  are real.
- **Settings tab** covering team details, account, security, collection
  defaults, data export/erase, and an About screen.
- **App Lock** using `LocalAuthentication` — Face ID / Touch ID / device
  passcode, engaging whenever the app leaves the foreground (including the
  app-switcher snapshot, so balances aren't visible in multitasking).
  Uses `.deviceOwnerAuthentication` so an unavailable or locked-out biometric
  always falls back to the passcode rather than stranding the user.
- **CSV export** for family balances, payments, and expenses, shared as real
  `.csv` files. With no backend and no backup, this is currently the only way
  to get data off the device or hand the books to next season's treasurer.
- **Erase all data**, behind a destructive confirmation.
- **Search** in Families (parent, player, email) and Expenses (title, category,
  note).
- The season report now carries the real team name, season, and treasurer
  instead of a hardcoded title.

### Added
- Unit test target (`dev1Tests`) using Swift Testing, covering the model
  layer (`FamilyMember`, `FeeCampaign`, `Payment`) and pure business logic
  (`FeeCalculator`, `CurrencyInput`).
- Shared Xcode scheme (`dev1.xcscheme`) so builds and tests are reproducible
  outside of one developer's local Xcode state.
- GitHub Actions CI (`.github/workflows/ios.yml`) building and testing on
  every push and pull request.
- `PrivacyInfo.xcprivacy` privacy manifest (currently declares no tracking
  and no data collection, matching the app's actual behavior).
- `FeeCalculator`: processing-fee math extracted out of `CollectPaymentView`
  into a pure, unit-tested type.
- `CurrencyInput`: locale-aware amount parsing and validation (positive,
  ≤2 decimal places, sane upper bound) used by all three "add" flows.
- User-facing error alerts on save failures in campaign/family/expense
  creation, replacing silently swallowed errors.
- Destructive-action confirmation dialogs before deleting a family or a
  campaign, since both cascade-delete payment history.
- VoiceOver accessibility labels/values on stat rows, list rows, and
  payment action buttons.
- `.gitignore` for standard Xcode artifacts; untracked `xcuserdata/`
  (local IDE state that shouldn't be version-controlled).
- Documentation: `README.md`, `docs/ARCHITECTURE.md`, `docs/DEPLOYMENT.md`.

- Visual design system (`Support/Theme.swift`): brand palette, spacing and
  radius scales, rounded figure typography, and a reusable card treatment.
- Reusable UI components: `StatTile`, `ProgressMeter`, `Avatar`,
  `StatusBadge`/`MetaBadge`, `EmptyStateView`, and `ExpenseBreakdownChart`
  (Swift Charts, no third-party dependency).

### Changed
- **Full interface redesign.** Replaced stock `List` styling throughout with a
  card-based layout on a tinted plane: a hero net-balance figure and KPI tiles
  on the dashboard, inline progress meters on campaign and payment rows,
  monogram avatars on roster rows, category glyphs on expenses, and designed
  empty states. The app now has a brand identity (indigo) rather than default
  system blue.
- Payment status is now communicated with an **icon and a text label**, not
  color alone. This is a correctness fix, not a style choice: the status green
  and status red measure ΔE 4.1 apart under simulated deuteranopia — far below
  the ≥8 separation target — so "Paid" and "Unpaid" were previously
  indistinguishable for a red-green colorblind user. Amber additionally sits at
  1.83:1 on the light surface, under the 3:1 bar, with the same mitigation.
- Campaign detail now sorts unpaid families to the top, since that's the
  treasurer's actual working list.

## [0.1.0] — Initial MVP

- Fee campaigns with per-family balance fan-out and manual reminders.
- Per-family ledger (paid/owed, fee history).
- Expense tracking with category grouping and optional receipt photos.
- Simulated card/ACH collection flow with processing-fee pass-through.
- One-tap, shareable season financial report.
- Sample data seeded on first launch.
