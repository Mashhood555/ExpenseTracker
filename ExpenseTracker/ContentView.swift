//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by SomewherE on 07/07/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var showingAddExpense = false
    @State private var selectedCategory: ExpenseCategory? = nil

    // Filtered expenses based on selected category
    var filteredExpenses: [Expense] {
        if let category = selectedCategory {
            return expenses.filter { $0.category == category.rawValue }
        }
        return expenses
    }

    // Total amount for filtered expenses
    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Total Summary Card
                    SummaryCard(total: totalAmount, count: filteredExpenses.count)

                    // Category Filter
                    CategoryFilterView(selectedCategory: $selectedCategory)

                    // Expense List
                    List {
                        if filteredExpenses.isEmpty {
                            Section {
                                ContentUnavailableView(
                                    selectedCategory == nil ? "No Expenses Yet" : "No \(selectedCategory!.rawValue) Expenses",
                                    systemImage: "creditcard",
                                    description: Text(selectedCategory == nil ?
                                        "Tap the + button to add your first expense" :
                                        "Try selecting a different category or add a new expense")
                                )
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            ForEach(filteredExpenses) { expense in
                                ExpenseRow(expense: expense)
                            }
                            .onDelete(perform: deleteExpenses)
                        }
                    }
                    .listStyle(.plain)
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddExpense = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue, Color.purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !expenses.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
    }

    private func deleteExpenses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredExpenses[index])
            }
        }
    }
}

// Summary Card showing total amount
struct SummaryCard: View {
    let total: Double
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("Total Spent")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("$\(total, specifier: "%.2f")")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.primary)
            Text("\(count) \(count == 1 ? "expense" : "expenses")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// Horizontal scrolling category filter
struct CategoryFilterView: View {
    @Binding var selectedCategory: ExpenseCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" button
                CategoryChip(
                    title: "All",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                // Category buttons
                ForEach(ExpenseCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
}

// Individual category chip button
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.15))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// Individual expense row
struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack {
            Image(systemName: iconForCategory(expense.category))
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category)
                    .font(.headline)
                if let note = expense.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(expense.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }

    private func iconForCategory(_ category: String) -> String {
        ExpenseCategory(rawValue: category)?.icon ?? "ellipsis.circle"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
