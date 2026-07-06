//
//  Expense.swift
//  ExpenseTracker
//
//  Created by SomewherE on 07/07/2026.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var amount: Double
    var category: String
    var date: Date
    var note: String?

    init(amount: Double, category: String, date: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case bills = "Bills"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .entertainment: return "tv"
        case .shopping: return "bag"
        case .bills: return "doc.text"
        case .other: return "ellipsis.circle"
        }
    }
}
