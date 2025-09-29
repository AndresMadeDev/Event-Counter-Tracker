//
//  EventDetailScreen.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/24/25.
//

import SwiftUI
import Combine
import SwiftData

struct EventDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var event: Event
    
    @State private var date: Date = Calendar.current.startOfDay(for: .now)
    @State private var selecteeColor: Color = .green
    @State private var timeRemaining: TimeInterval = 0
    @State private var isEventPassed = false
    @State private var showEdit: Bool = false
    @State private var showAlert: Bool = false
    @State private var showCreateTodo: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(event.eventType)
                            .font(.headline)
                        Text(event.title)
                            .font(.title)
                            .bold()
                            .foregroundStyle(event.hexColor)
                    }
                    
                    HStack {
                        Text(event.dayOfEvent.formatted(.dateTime.month(.wide).day()))
                            .font(.headline)
                        Spacer()
                        Button("", systemImage: "pencil.line") {
                            showEdit.toggle()
                        }
                    }
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
                    
                    if !isEventPassed {
                        Divider()
                            .padding(.vertical)
                        
                        HStack {
                            VStack {
                                Text(event.dayComponents(for: Int(timeRemaining)))
                                    .font(.system(size: 50, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.3)
                                    .foregroundStyle(event.hexColor)
                                    .fontWeight(.semibold)
                                    .frame(height: 75)
                                    .frame(maxWidth: .infinity)
                                    .glassEffect(.clear, in: .rect(cornerRadius: 20))
                                Text("Days")
                                    .font(.subheadline)
                            }
                            if event.addHour {
                                VStack {
                                    Text(event.hourComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 50, weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .foregroundStyle(event.hexColor)
                                        .fontWeight(.semibold)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                                    Text("Hours")
                                        .font(.subheadline)
                                }
                            }
                            
                            if event.addMinutes {
                                VStack {
                                    Text(event.minutesComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 50, weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .foregroundStyle(event.hexColor)
                                        .fontWeight(.semibold)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                                    //                                        .foregroundStyle(event.hexColor)
                                    //                                        .background(.ultraThinMaterial)
                                    //                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    Text("Min")
                                        .font(.subheadline)
                                    //                                        .foregroundStyle(Color(.systemGray))
                                }
                            }
                            
                            if event.addSeconds {
                                VStack {
                                    Text(event.secondsComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 50, weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .foregroundStyle(event.hexColor)
                                        .fontWeight(.semibold)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .glassEffect(.clear, in: .rect(cornerRadius: 20))
                                    Text("Sec")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(.clear, in: .rect(cornerRadius: 10))
                
                
                    if event.todo?.count ?? 0 > 0 {
                        TodoListView(todo: event.todo ?? [], event: event)
                            .listStyle(.plain)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top)
                    } else {
                        ContentUnavailableView("There is no task for this event!", systemImage: "list.bullet")
                            .foregroundStyle(event.hexColor)
                            .glassEffect(.clear, in: .rect(cornerRadius: 10))
                    }
                
                
                
                Spacer()
                
                
            }
            .padding()
            .background(event.hexColor.opacity(0.3))
            .onAppear {
                updateCountdown()
                //            WidgetCenter.shared.reloadAllTimelines()
            }
            .onReceive(timer) { _ in
                updateCountdown()
            }
            .sheet(isPresented: $showEdit, content: {
                EditDetailScreen(event: event)
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete", systemImage: "trash") {
                        showAlert.toggle()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(event.hexColor)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { creatTodo() }, label: {
                        Text("+ Task")
                            .font(.title3)
                            .frame(width: 200)
                    })
                    .buttonStyle(.glassProminent)
                    .tint(event.hexColor)
                }
            }
            .alert("Delete \(event.title)", isPresented: $showAlert, actions: {
                Button("Cancel", role: .cancel) {}
                Button("OK") {
                    deleteEvent()
                }
            }, message: {
                Text("Are you sure you would like to delete \(event.title)?")
            })
        }
    }
    
    /// Deletes the current event from the model context and dismisses this screen.
    func deleteEvent() {
        // NotificationManager.shared.removeNotification(for: event)
        modelContext.delete(event)
        // WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }

    func updateCountdown() {
        let eventDate = event.dayOfEvent
        timeRemaining = eventDate.timeIntervalSinceNow
        if timeRemaining <= 0 {
            isEventPassed = true
            timeRemaining = 0
        } else {
            isEventPassed = false
        }
    }
    
    func creatTodo() {
        showCreateTodo.toggle()
        let newTodo = TodoList(title: "New Task", detail: "", completed: false)
        if event.todo == nil {
            event.todo = []
        }
        event.todo?.append(newTodo)
        try? modelContext.save()
//        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func delete() {
//        for i in indexSet {
//            let todo = event.todo?[i]
//            modelContext.delete(todo!)
////            WidgetCenter.shared.reloadAllTimelines()
//            
//        }
    }
    
    func emptyTodo() {
        if ((event.todo?.isEmpty) != nil) {
            event.addList = false
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailScreen(event: Event.sample)
    }
}

