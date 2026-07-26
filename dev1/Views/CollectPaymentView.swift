//
//  CollectPaymentView.swift
//  dev1
//

import SwiftUI

struct CollectPaymentView: View {
    @Bindable var payment: Payment
    @Environment(\.dismiss) private var dismiss

    @State private var method: PaymentMethod = .card
    @State private var passFeeToFamily = true
    @State private var isProcessing = false

    enum PaymentMethod: String, CaseIterable, Identifiable {
        case card = "Card"
        case ach = "Bank (ACH)"
        var id: String { rawValue }

        var calculatorMethod: FeeCalculator.Method {
            switch self {
            case .card: return .card
            case .ach: return .ach
            }
        }
    }

    private var platformFee: Decimal {
        FeeCalculator.processingFee(on: payment.balanceRemaining, method: method.calculatorMethod)
    }

    private var totalCharged: Decimal {
        FeeCalculator.totalCharge(
            forBalance: payment.balanceRemaining,
            method: method.calculatorMethod,
            passFeeToPayer: passFeeToFamily
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Space.lg) {
                    amountCard
                    methodCard
                    summaryCard
                    simulationNotice
                }
                .padding(Theme.Space.lg)
            }
            .background(Theme.plane)
            .navigationTitle("Collect Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                chargeButton
                    .padding(Theme.Space.lg)
                    .background(.bar)
            }
        }
    }

    private var amountCard: some View {
        VStack(spacing: Theme.Space.xs) {
            if let name = payment.family?.parentName {
                Avatar(name: name, size: 48)
                Text(name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.inkSecondary)
                    .padding(.top, Theme.Space.xs)
            }
            Text(payment.balanceRemaining.currencyString)
                .font(Theme.figure(44, weight: .bold))
                .foregroundStyle(Theme.inkPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("Balance due")
                .font(.system(size: 12))
                .foregroundStyle(Theme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .card(padding: Theme.Space.xl)
    }

    private var methodCard: some View {
        VStack(alignment: .leading, spacing: Theme.Space.md) {
            Text("Payment method")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.inkSecondary)

            Picker("Method", selection: $method) {
                ForEach(PaymentMethod.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $passFeeToFamily) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pass processing fee to family")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.inkPrimary)
                    Text("Off means the team absorbs it")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .tint(Theme.accent)
        }
        .card()
    }

    private var summaryCard: some View {
        VStack(spacing: Theme.Space.md) {
            row("Balance", payment.balanceRemaining.currencyString, muted: true)
            row("Processing fee", platformFee.currencyString, muted: true)
            Divider()
            row("Total charged", totalCharged.currencyString, muted: false)
        }
        .card()
    }

    private func row(_ label: String, _ value: String, muted: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: muted ? 13 : 15, weight: muted ? .regular : .semibold))
                .foregroundStyle(muted ? Theme.inkSecondary : Theme.inkPrimary)
            Spacer()
            Text(value)
                .font(Theme.figure(muted ? 14 : 18, weight: muted ? .medium : .bold))
                .foregroundStyle(muted ? Theme.inkSecondary : Theme.inkPrimary)
        }
    }

    private var simulationNotice: some View {
        HStack(alignment: .top, spacing: Theme.Space.sm) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(Theme.statusWarning)
            Text("Simulated checkout \u{2014} no card is charged and no money moves. Production hands off to Stripe\u{2019}s PaymentSheet.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Space.md)
        .background(Theme.statusWarning.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
    }

    private var chargeButton: some View {
        Button {
            processPayment()
        } label: {
            Group {
                if isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Text("Charge \(totalCharged.currencyString)")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Space.lg)
            .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.Radius.control, style: .continuous))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
        .accessibilityLabel(isProcessing ? "Processing payment" : "Charge \(totalCharged.currencyString)")
    }

    private func processPayment() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            payment.recordPayment(amount: payment.balanceRemaining)
            isProcessing = false
            dismiss()
        }
    }
}
