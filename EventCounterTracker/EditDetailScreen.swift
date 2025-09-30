//
//  EditDetailScreen.swift
//  EventCounterTracker
//
//  Created by Andres Made on 9/29/25.
//

import SwiftUI
import Combine
import UserNotifications
import SwiftData

struct EditDetailScreen: View {
    @Bindable var event: Event
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
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
            .onDisappear {
                Task {
                    await rescheduleNotification()
                }
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
    
    @MainActor
    private func rescheduleNotification() async {
        let center = UNUserNotificationCenter.current()

        // Check authorization status
        let status = await getAuthorizationStatus(center: center)
        switch status {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined:
            do {
                let granted = try await requestAuthorization(center: center)
                if !granted { return }
            } catch {
                return
            }
        case .denied:
            return
        @unknown default:
            return
        }

        // Remove existing notification if any
        if let id = event.notificationID {
            center.removePendingNotificationRequests(withIdentifiers: [id])
            center.removeDeliveredNotifications(withIdentifiers: [id])
        }

        // Only schedule for a future date
        let triggerDate = event.dayOfEvent
        if triggerDate <= Date() { return }

        // Build date components according to the event's time granularity
        var components: Set<Calendar.Component> = [.year, .month, .day]
        if event.addHour { components.insert(.hour) }
        if event.addMinutes { components.insert(.minute) }
        if event.addSeconds { components.insert(.second) }

        let triggerComponents = Calendar.current.dateComponents(components, from: triggerDate)

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Event Counter"
        let bodyText = notificationText.isEmpty ? "Get ready for \(event.title)" : notificationText
        content.body = bodyText
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                center.add(request) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
            // Save the new identifier on the event
            event.notificationID = identifier
            try? modelContext.save()
        } catch {
            // Swallow errors silently in edit flow
        }
    }

    private func getAuthorizationStatus(center: UNUserNotificationCenter) async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    private func requestAuthorization(center: UNUserNotificationCenter) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}

