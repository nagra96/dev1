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
        case ach = "ACH Bank Transfer"
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
        FeeCalculator.totalCharge(forBalance: payment.balanceRemaining, method: method.calculatorMethod, passFeeToPayer: passFeeToFamily)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Balance") {
                    HStack {
                        Text("Amount Due")
                        Spacer()
                        Text(payment.balanceRemaining.currencyString)
                    }
                }

                Section("Payment Method") {
                    Picker("Method", selection: $method) {
                        ForEach(PaymentMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("Pass processing fee to family", isOn: $passFeeToFamily)
                }

                Section("Summary") {
                    HStack {
                        Text("Processing Fee")
                        Spacer()
                        Text(platformFee.currencyString)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Total Charged")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(totalCharged.currencyString)
                            .fontWeight(.semibold)
                    }
                }

                Section {
                    Text("This is a simulated checkout for demo purposes. In production this screen hands off to Stripe\u{2019}s PaymentSheet for card/ACH collection.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Collect Payment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        processPayment()
                    } label: {
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Charge \(totalCharged.currencyString)")
                        }
                    }
                    .disabled(isProcessing)
                    .accessibilityLabel(isProcessing ? "Processing payment" : "Charge \(totalCharged.currencyString)")
                }
            }
        }
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
