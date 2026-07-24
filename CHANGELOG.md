# Changelog

All notable changes to this project are documented in this file. Format
loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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

### Changed
- N/A (first documented pass over the initial MVP).

## [0.1.0] — Initial MVP

- Fee campaigns with per-family balance fan-out and manual reminders.
- Per-family ledger (paid/owed, fee history).
- Expense tracking with category grouping and optional receipt photos.
- Simulated card/ACH collection flow with processing-fee pass-through.
- One-tap, shareable season financial report.
- Sample data seeded on first launch.
