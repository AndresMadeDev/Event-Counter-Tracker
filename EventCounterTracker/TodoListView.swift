//
//  TodoListView.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/24/25.
//

import SwiftUI

struct TodoListView: View {
    @Environment(\.modelContext) var modelContext
    @State private var showEdit: Bool = false
    var todo: [TodoList]
    var event: Event
    
    var body: some View {
        List(todo) { todo in
            Text("Hello, World!")
        }
        
    }
}


