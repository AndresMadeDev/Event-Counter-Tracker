//
//  CreateEventScreen.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import SwiftUI
import SwiftData

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
//                    WidgetCenter.shared.reloadAllTimelines()
                    scheduleNotification()
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
//                    WidgetCenter.shared.reloadAllTimelines()
                    dismiss()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Event Counter"
        content.body = notificationText.isEmpty ? "Get ready for \(name)" : notificationText
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                alertMessage = "Error scheduling notification: \(error.localizedDescription)"
            } else {
                alertMessage = "\(name) was scheduled successfully for \(date.formatted(.dateTime.month().day().year()))"
            }
            showAlert = true
        }
    }
}

#Preview {
    CreateEventScreen()
}
