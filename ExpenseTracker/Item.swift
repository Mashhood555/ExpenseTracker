//
//  Item.swift
//  ExpenseTracker
//
//  Created by SomewherE on 07/07/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
