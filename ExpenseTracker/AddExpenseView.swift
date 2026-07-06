//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by SomewherE on 07/07/2026.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var category: ExpenseCategory = .food
    @State private var date: Date = Date()
    @State private var note: String = ""

    // Computed property to validate form
    var isValid: Bool {
        guard let amount = Double(amountText) else { return false }
        return amount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                // Amount Section
                Section {
                    HStack {
                        Text("$")
                            .font(.title)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                } header: {
                    Text("Amount")
                } footer: {
                    if !amountText.isEmpty && !isValid {
                        Text("Please enter a valid amount")
                            .foregroundColor(.red)
                    }
                }

                // Category Section
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Date Section
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                // Note Section
                Section("Note (Optional)") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveExpense() {
        guard let amount = Double(amountText), amount > 0 else { return }

        let newExpense = Expense(
            amount: amount,
            category: category.rawValue,
            date: date,
            note: note.isEmpty ? nil : note
        )

        modelContext.insert(newExpense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: Expense.self, inMemory: true)
}
