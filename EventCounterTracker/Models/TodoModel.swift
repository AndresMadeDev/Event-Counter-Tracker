//
//  TodoModel.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import Foundation
import SwiftData

@Model
class TodoList {
    var title: String = ""
    var detail: String = ""
    var completed: Bool = false
    var amountCompleted: Double = 0.0
    var createdAt: Date = Date.now
    var event: Event?
    
    init(title: String, detail: String, completed: Bool) {
        self.title = title
        self.detail = detail
        self.completed = completed
    }
}
