//
//  SummaryView.swift
//  ExpenseTracker
//
//  Created by SomewherE on 07/07/2026.
//

import SwiftUI
import SwiftData
import Charts

struct SummaryView: View {
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @State private var selectedPeriod: SummaryPeriod = .month

    // Filter expenses by selected period
    var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .week:
            return allExpenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .month:
            return allExpenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            }
        case .year:
            return allExpenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            }
        }
    }

    // Total amount for filtered expenses
    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    // Group expenses by category and sum amounts
    var categoryBreakdown: [(category: ExpenseCategory, amount: Double)] {
        var breakdown: [ExpenseCategory: Double] = [:]

        for expense in filteredExpenses {
            if let category = ExpenseCategory(rawValue: expense.category) {
                breakdown[category, default: 0] += expense.amount
            }
        }

        return breakdown.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(SummaryPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Total Card
                    VStack(spacing: 8) {
                        Text("Total Spent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(totalAmount, specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold))
                        Text("\(filteredExpenses.count) \(filteredExpenses.count == 1 ? "expense" : "expenses")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Category Breakdown Chart
                    if !categoryBreakdown.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending by Category")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(categoryBreakdown, id: \.category) { item in
                                BarMark(
                                    x: .value("Amount", item.amount),
                                    y: .value("Category", item.category.rawValue)
                                )
                                .foregroundStyle(Color.blue.gradient)
                                .annotation(position: .trailing) {
                                    Text("$\(item.amount, specifier: "%.0f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(position: .bottom) { value in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let amount = value.as(Double.self) {
                                            Text("$\(Int(amount))")
                                        }
                                    }
                                }
                            }
                            .frame(height: CGFloat(categoryBreakdown.count * 50))
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Category List
                        VStack(spacing: 8) {
                            ForEach(categoryBreakdown, id: \.category) { item in
                                CategoryBreakdownRow(
                                    category: item.category,
                                    amount: item.amount,
                                    total: totalAmount
                                )
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        ContentUnavailableView(
                            "No Data",
                            systemImage: "chart.bar",
                            description: Text("Add expenses to see your spending breakdown")
                        )
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

enum SummaryPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}

struct CategoryBreakdownRow: View {
    let category: ExpenseCategory
    let amount: Double
    let total: Double

    var percentage: Double {
        total > 0 ? (amount / total) * 100 : 0
    }

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 6)
                            .cornerRadius(3)

                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(amount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(percentage, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    SummaryView()
        .modelContainer(for: Expense.self, inMemory: true)
}
