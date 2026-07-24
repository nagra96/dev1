# Architecture

## Stack

SwiftUI + SwiftData, no third-party dependencies. There's no separate
ViewModel layer: views own an `@Query` or `@Bindable` model reference
directly and mutate it, which is the pattern Apple's own SwiftData tooling
is built around (`@Query` invalidates and re-renders the view automatically
when the underlying store changes). Business logic that doesn't belong in a
view — fee math, currency parsing — lives in plain, dependency-free types
under `Support/` so it can be unit tested without standing up a `View` or a
`ModelContext`.

## Data model

Four `@Model` types, all in `dev1/Models/`:

```
FamilyMember ──┐
               ├──< Payment >──┐
FeeCampaign ───┘               │
                                └── (amountDue, amountPaid, status, reminderSentDate)

Expense (standalone — not tied to a family or campaign)
```

- **`FeeCampaign`** is the thing a treasurer creates ("Uniform Fee, $150,
  due March 1"). Creating one fans out a `Payment` row to every
  `FamilyMember` currently on the roster (`NewCampaignView.createCampaign`).
  Families added *after* a campaign exists are **not** retroactively billed
  — that's a deliberate MVP simplification, not an oversight; see the open
  question in `docs/DEPLOYMENT.md`.
- **`Payment`** is the join row and the unit of money movement: it tracks
  `amountDue`/`amountPaid`, derives `status` (`unpaid` / `partial` / `paid`)
  and `balanceRemaining`, and records `reminderSentDate` for the "remind
  unpaid families" flow.
- **`FamilyMember.totalOwed`/`totalPaid`** and **`FeeCampaign.totalCollected`/
  `totalExpected`** are computed properties over the family's or campaign's
  `Payment` relationship — there's no separately maintained running balance
  to keep in sync, which avoids a whole class of bugs where a cached total
  drifts from its source rows.
- **`Expense`** is intentionally simple and unrelated to campaigns/payments:
  it's the club's spending side of the ledger, not the collection side.
  Receipt photos are stored as `@Attribute(.externalStorage)` `Data` so
  SwiftData keeps large blobs out of the main store file.

Relationships use SwiftData's `inverse:` on the "many" side only
(`FamilyMember.payments` and `FeeCampaign.payments` each declare
`.cascade` delete rules), matching SwiftData's documented pattern — deleting
a family or a campaign deletes its `Payment` rows with it, which is why the
UI puts a destructive confirmation in front of both of those deletes (see
`FamiliesListView`/`CampaignsListView`) but not in front of expense
deletion, which only removes a single row.

## Key flows

- **Campaign creation** (`NewCampaignView`): validates the amount via
  `CurrencyInput`, creates the `FeeCampaign`, inserts one `Payment` per
  current family, and saves in a single `ModelContext` transaction — either
  all of it lands or none of it does (`context.rollback()` on failure).
- **Reminders** (`CampaignDetailView.sendReminders`): stamps
  `Payment.reminderSentDate` on the selected payments. This is a **local UI
  action only** — no email/SMS/push is actually sent. See
  `docs/DEPLOYMENT.md` for what turning this into a real reminder system
  requires.
- **Payment collection** (`CollectPaymentView`): computes a processing fee
  via `FeeCalculator` (Stripe's published card and ACH rates), optionally
  passes it through to the payer, and after a short simulated delay calls
  `Payment.recordPayment`. **No money actually moves** — see
  `docs/DEPLOYMENT.md` for the real Stripe integration plan.
- **Season report** (`SeasonReportView`): a pure read-side view that
  aggregates the same computed properties used elsewhere (`totalCollected`,
  `totalOwed`, etc.) into a text report, shared via `ShareLink`.

## Error handling

Every user-initiated write (`context.save()` in the three "New…" views and
the destructive deletes) is wrapped in `do`/`catch`: a failed save rolls the
context back via `context.rollback()` and either surfaces an alert (for
creates) or logs via `os.Logger` (for deletes, which are rare-failure and
lower-stakes). `SeedData` logs rather than crashing on failure so a corrupt
first-launch seed doesn't take down an otherwise-working app.

`CurrencyInput` exists because `Decimal(string:)` always assumes `.` as the
decimal separator regardless of device locale — on a locale where the
decimal pad shows a comma, that silently mis-parses input. It tries the
current locale first, falls back to `.`, and rejects non-positive amounts,
amounts with more than two decimal places, and implausibly large amounts
(a typo guard, not a real business limit).

## What's local-only today

There is no backend and no multi-device sync. Every install has its own
SwiftData store; if the treasurer collects a payment on their phone, the
club president's iPad has no way to know about it. That's fine for a
single-device demo and is the biggest gap between this MVP and a shippable
multi-user product — see the "Sync and multi-user access" section of
`docs/DEPLOYMENT.md`.
