//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by SomewherE on 07/07/2026.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Expense.self)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Expenses", systemImage: "creditcard")
                }

            SummaryView()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar")
                }
        }
    }
}
