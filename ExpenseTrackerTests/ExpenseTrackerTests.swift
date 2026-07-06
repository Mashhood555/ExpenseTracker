//
//  ExpenseTrackerTests.swift
//  ExpenseTrackerTests
//
//  Created by SomewherE on 07/07/2026.
//

import Testing
import Foundation
import SwiftData
@testable import ExpenseTracker

@MainActor
@Suite struct ExpenseTrackerTests {

    @Test func testExpenseCreation() throws {
        // Create a test expense
        let expense = Expense(
            amount: 25.50,
            category: ExpenseCategory.food.rawValue,
            date: Date(),
            note: "Lunch"
        )

        // Verify properties
        #expect(expense.amount == 25.50)
        #expect(expense.category == "Food")
        #expect(expense.note == "Lunch")
        #expect(expense.id != UUID()) // Should have generated ID
    }

    @Test func testCategoryIcons() throws {
        // Verify all categories have icons
        for category in ExpenseCategory.allCases {
            #expect(!category.icon.isEmpty)
        }
    }

    @Test func testExpensePersistence() throws {
        // Test saving to SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Expense.self, configurations: config)

        let context = container.mainContext
        let expense = Expense(
            amount: 100.0,
            category: ExpenseCategory.bills.rawValue,
            note: "Electric bill"
        )

        context.insert(expense)
        try context.save()

        // Fetch and verify
        let descriptor = FetchDescriptor<Expense>()
        let expenses = try context.fetch(descriptor)

        #expect(expenses.count == 1)
        #expect(expenses.first?.amount == 100.0)
        #expect(expenses.first?.category == "Bills")
    }
}
