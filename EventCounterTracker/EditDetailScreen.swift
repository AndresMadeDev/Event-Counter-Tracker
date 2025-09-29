//
//  EditDetailScreen.swift
//  EventCounterTracker
//
//  Created by Andres Made on 9/29/25.
//

import SwiftUI
import Combine

struct EditDetailScreen: View {
    @Bindable var event: Event
    @Environment(\.dismiss) var dismiss
    
    @State private var date: Date = Calendar.current.startOfDay(for: .now)
    @State private var selecteeColor: Color = .green
    @State private var timeRemaining: TimeInterval = 0
    @State private var isEventPassed = false
    @State private var notificationText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
   
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Edit Event Title") {
                    TextField("Event Title: \(event.title)", text: $event.title)
                        .font(.headline)
                    Picker("Edit Type \(event.eventType)", selection: $event.eventType) {
                        ForEach(Emoji.allCases, id: \.self) { emoli in
                            Text(emoli.description).tag(emoli.rawValue)
                        }
                    }
                }
                
                //            Section("Edit Event Color") {
                //                ColorPicker("Event Color", selection: $event.hexColor)
                //            }
                
                Section("Edit Event's Date") {
                    if event.addHour == true  || event.addMinutes == true  || event.addSeconds == true {
                        DatePicker("Event Date", selection: $event.dayOfEvent)
                    } else {
                        DatePicker("Event Date", selection: $event.dayOfEvent, displayedComponents: .date)
                    }
                    
                    HStack {
                        Text("Day")
                            .font(.headline)
                            .padding(12)
                            .foregroundStyle(.white)
                            .background(event.hexColor)
                            .clipShape(.rect(cornerRadius: 10))
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    event.addTime.toggle()
                                }
                            }
                        Spacer()
                        Text("Hour")
                            .font(.headline)
                            .padding(12)
                            .foregroundStyle(.white)
                            .background(event.addHour ? event.hexColor : Color(.systemGray))
                            .clipShape(.rect(cornerRadius: 10))
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    event.addHour.toggle()
                                }
                            }
                        Spacer()
                        Text("Min")
                            .font(.headline)
                            .padding(12)
                            .foregroundStyle(.white)
                            .background(event.addMinutes ? event.hexColor : Color(.systemGray))
                            .clipShape(.rect(cornerRadius: 10))
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    event.addMinutes.toggle()
                                }
                            }
                        Spacer()
                        Text("Sec")
                            .font(.headline)
                            .padding(12)
                            .foregroundStyle(.white)
                            .background(event.addSeconds ? event.hexColor : Color(.systemGray))
                            .clipShape(.rect(cornerRadius: 10))
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    event.addSeconds.toggle()
                                }
                            }
                    }
                }
            }
            .navigationTitle("Edit: \(event.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                //            WidgetCenter.shared.reloadAllTimelines()
                updateCountdown()
            }
            .onReceive(timer) { _ in
                updateCountdown()
            }
            .onDisappear{
                //            scheduleNotification()
                //            WidgetCenter.shared.reloadAllTimelines()
            }
        }
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
    
//    func scheduleNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "Event Counter"
//        content.body = notificationText.isEmpty ? "Get ready for \(event.title)" : notificationText
//        content.sound = UNNotificationSound.default
//
//        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: event.dayOfEvent)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                alertMessage = "Error scheduling notification: \(error.localizedDescription)"
//            } else {
//                alertMessage = "\(event.title) was scheduled successfully for \(date.formatted(.dateTime.month().day().year()))"
//            }
//            showAlert = true
//        }
//    }
}

