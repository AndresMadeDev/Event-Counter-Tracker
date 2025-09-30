//
//  CreateEventScreen.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct CreateEventScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedType: Emoji = .other
    @State private var name: String = ""
    @State private var date: Date = Calendar.current.startOfDay(for: .now)
    @State private var color: Color = .blue
    @State private var addList: Bool = false
    @State private var addTime: Bool = true
    @State private var addHours: Bool = true
    @State private var addMinutes: Bool = true
    @State private var addSeconds: Bool = true
    @State private var notificationText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Enter Event Name", text: $name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Picker("Type of event: \(selectedType.rawValue)", selection: $selectedType) {
                    ForEach(Emoji.allCases, id: \.self) { emoji in
                        Text(emoji.description).tag(emoji)
                    }
                }
            }
            
            Section {
                if addHours == true  || addMinutes == true  || addSeconds == true {
                    DatePicker("Event Date", selection: $date)
                } else {
                    DatePicker("Event Date", selection: $date, displayedComponents: .date)
                }
                
                HStack {
                    Text("Day")
                        .font(.headline)
                        .padding(12)
                        .foregroundStyle(.white)
                        .background(addTime ? color : Color(.systemGray))
                        .clipShape(.rect(cornerRadius: 10))
                        .onTapGesture {
                            withAnimation(.snappy) {
                                addTime.toggle()
                            }
                        }

                    Spacer()
                    Text("Hour")
                        .font(.headline)
                        .padding(12)
                        .foregroundStyle(.white)
                        .background(addHours ? color : Color(.systemGray))
                        .clipShape(.rect(cornerRadius: 10))
                        .onTapGesture {
                            withAnimation(.snappy) {
                                addHours.toggle()
                            }
                        }
                    
                    Spacer()
                    Text("Min")
                        .font(.headline)
                        .padding(12)
                        .foregroundStyle(.white)
                        .background(addMinutes ? color : Color(.systemGray))
                        .clipShape(.rect(cornerRadius: 10))
                        .onTapGesture {
                            withAnimation(.snappy) {
                                addMinutes.toggle()
                            }
                        }
                    
                    Spacer()
                    Text("Sec")
                        .font(.headline)
                        .padding(12)
                        .foregroundStyle(.white)
                        .background(addSeconds ? color : Color(.systemGray))
                        .clipShape(.rect(cornerRadius: 10))
                        .onTapGesture {
                            withAnimation(.snappy) {
                                addSeconds.toggle()
                            }
                        }
                }
            }
            
            Section {
                VStack(alignment: .leading,spacing: 20) {
                    Text("Event Color")
                    
                    CustomColorPickerView(selectedColor: $color)
         
                    Divider()
                    
                    ColorPicker(selection: $color, label: {
                        Text("Custom Color")
                    })
                }
                .padding(.vertical, 3)
            }
        }
        .navigationTitle("New Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create") {
                    let newEvent = Event(title: name, eventColor: color.toHexString() ?? "", dayOfEvent: date, eventType: selectedType.rawValue, addList: addList, addTime: addTime, addHours: addHours, addMinutes: addMinutes, addSeconds: addSeconds)
                    modelContext.insert(newEvent)
                    Task {
                        if let id = await scheduleNotification() {
                            newEvent.notificationID = id
                            try? modelContext.save()
                        }
                    }
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    @MainActor
    private func scheduleNotification() async -> String? {
        let center = UNUserNotificationCenter.current()
        do {
            let status = await getAuthorizationStatus(center: center)
            switch status {
            case .authorized, .provisional, .ephemeral:
                break
            case .notDetermined:
                let granted = try await requestAuthorization(center: center)
                if !granted {
                    alertMessage = "Notifications are disabled. Enable them in Settings to get reminders."
                    showAlert = true
                    return nil
                }
            case .denied:
                alertMessage = "Notifications are disabled. Enable them in Settings to get reminders."
                showAlert = true
                return nil
            @unknown default:
                alertMessage = "Unknown notification authorization status."
                showAlert = true
                return nil
            }

            let id = try await scheduleNotificationRequest(center: center)
            let includeTime = (addHours || addMinutes || addSeconds)
            alertMessage = "\(name) was scheduled for \(formatDateForAlert(date: date, includeTime: includeTime))"
            showAlert = true
            return id
        } catch {
            alertMessage = "Error scheduling notification: \(error.localizedDescription)"
            showAlert = true
            return nil
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

    private enum NotificationScheduleError: LocalizedError {
        case pastDate
        var errorDescription: String? {
            switch self {
            case .pastDate:
                return "Choose a future date and time to schedule a notification."
            }
        }
    }

    private func scheduleNotificationRequest(center: UNUserNotificationCenter) async throws -> String {
        let triggerDate = date
        if triggerDate <= Date() {
            throw NotificationScheduleError.pastDate
        }

        var components: Set<Calendar.Component> = [.year, .month, .day]
        if addHours { components.insert(.hour) }
        if addMinutes { components.insert(.minute) }
        if addSeconds { components.insert(.second) }

        let triggerComponents = Calendar.current.dateComponents(components, from: triggerDate)

        let content = UNMutableNotificationContent()
        content.title = "Event Counter"
        content.body = notificationText.isEmpty ? "Get ready for \(name)" : notificationText
        content.sound = UNNotificationSound.default

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false))

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        return identifier
    }

    private func formatDateForAlert(date: Date, includeTime: Bool) -> String {
        if includeTime {
            return date.formatted(.dateTime.month().day().year().hour().minute())
        } else {
            return date.formatted(.dateTime.month().day().year())
        }
    }
}

#Preview {
    CreateEventScreen()
}
