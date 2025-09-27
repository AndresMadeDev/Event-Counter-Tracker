//
//  TodoListView.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/24/25.
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) var modelContext
    @State private var showEdit: Bool = false
    var todo: [TodoList]
    var event: Event
    
    var body: some View {
        List {
            ForEach(todo) { item in
                TodoRowView(item: item, tintColor: event.hexColor)
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = todo[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}

struct TodoRowView: View {
    @Environment(\.modelContext) private var modelContext
    var item: TodoList
    var tintColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Button {
                item.completed.toggle()
                try? modelContext.save()
            } label: {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.completed ? tintColor : .secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            TextField("Todo", text: Binding(
                get: { item.title },
                set: { newValue in
                    item.title = newValue
                }
            ))
                .textFieldStyle(.plain)
                .strikethrough(item.completed, color: tintColor)
                .foregroundStyle(item.completed ? .secondary : .primary)
                .onSubmit {
                    try? modelContext.save()
                }
        }
        .padding(.vertical, 4)
    }
}

