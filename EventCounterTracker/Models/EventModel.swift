//
//  EventModel.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Event {
    var title: String = ""
    var eventColor: String = "FF0000"
    var dayOfEvent: Date = Date.now
    var eventType: String = Emoji.holiday.rawValue
    var addList: Bool = false
    var addTime: Bool = true
    var addHour: Bool = true
    var addMinutes: Bool = true
    var addSeconds: Bool = true
    @Relationship(deleteRule: .cascade) var todo: [TodoList]?
    
    init(title: String, eventColor: String, dayOfEvent: Date, eventType: String, addList: Bool, addTime: Bool, addHours: Bool, addMinutes: Bool, addSeconds: Bool) {
        self.title = title
        self.eventColor = eventColor
        self.dayOfEvent = dayOfEvent
        self.eventType = eventType
        self.addList = addList
        self.addTime = addTime
        self.addHour = addHours
        self.addMinutes = addMinutes
        self.addSeconds = addSeconds
    }
    
    var hexColor: Color {
        Color(hex: self.eventColor) ?? .blue
    }
    
    func daysBetween(_ startDate: Date, _ endDate: Date) -> Int {
        let calendar = Calendar.current
       
        let startMidnight = calendar.startOfDay(for: startDate)
        let endMidnight = calendar.startOfDay(for: endDate)
        
        let components = calendar.dateComponents([.day], from: startMidnight, to: endMidnight)
        return (components.day ?? 0)
    }
    
    func timeString(for seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
    }
    
    func timeComponents(for seconds: Int) -> String {
          let days = seconds / 86400
          let hours = (seconds % 86400) / 3600
          let minutes = (seconds % 3600) / 60
          let remainingSeconds = seconds % 60
          
          var components: [String] = []
          
          if days > 0 {
              components.append("\(days)d\(days == 1 ? "" : "")")
          }
          if hours > 0 {
              components.append("\(hours)h\(hours == 1 ? "" : "")")
          }
          if minutes > 0 {
              components.append("\(minutes)m\(minutes == 1 ? "" : "")")
          }
          if remainingSeconds > 0 || components.isEmpty {
              components.append("\(remainingSeconds)s\(remainingSeconds == 1 ? "" : "")")
          }
          
          return components.joined(separator: " : ")
      }
    
    func dayComponents(for seconds: Int) -> String {
        let days = seconds / 86400
        return days != 0 ? "\(days)" : "--"
    }
    
    func hourComponents(for seconds: Int) -> String {
        let hours = (seconds % 86400) / 3600
        return hours != 0 ? "\(hours)" : "--"
    }
    
    func hoursRemaining(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Set the target date to the end of the day (23:59:59)
        let targetEndOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        // Calculate the difference in hours
        let components = calendar.dateComponents([.hour], from: now, to: targetEndOfDay)
        let hours = max(0, components.hour ?? 0)
        
        return hours != 0 ? "\(hours)" : "--"
    }
    
    func minutesComponents(for seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        return minutes != 0 ? "\(minutes)" : "--"
    }
    
    func secondsComponents(for seconds: Int) -> String {
        let seconds = seconds % 60
        return seconds != 0 ? "\(seconds)" : "--"
    }
    
    var totalCompleted: Double {
        let sum = todo?.reduce(0, {$0 + $1.amountCompleted}) ?? 0.0
        return sum
    }
    
    var completedPercent: Double {
        Double(totalCompleted == 0 ? 0 : Int((totalCompleted))) / Double((todo?.count ?? Int(0.0)))
    }
    
    // MARK: - Sample Data

    static let sample: Event = Event(
        title: "Sample Event",
        eventColor: "FF6B6B",
        dayOfEvent: Calendar.current.date(byAdding: .day, value: 7, to: Date.now) ?? Date.now,
        eventType: Emoji.holiday.rawValue,
        addList: true,
        addTime: true,
        addHours: true,
        addMinutes: true,
        addSeconds: true
    )

    static let samples: [Event] = [
        Event(
            title: "Trip to Hawaii",
            eventColor: "FF6B6B",
            dayOfEvent: Calendar.current.date(byAdding: .day, value: 30, to: Date.now) ?? Date.now,
            eventType: Emoji.vacation.rawValue,
            addList: true,
            addTime: true,
            addHours: true,
            addMinutes: true,
            addSeconds: true
        ),
        Event(
            title: "John's Birthday",
            eventColor: "FFD166",
            dayOfEvent: Calendar.current.date(byAdding: .day, value: 10, to: Date.now) ?? Date.now,
            eventType: Emoji.birthday.rawValue,
            addList: false,
            addTime: true,
            addHours: true,
            addMinutes: true,
            addSeconds: true
        ),
        Event(
            title: "Quarterly Meeting",
            eventColor: "06D6A0",
            dayOfEvent: Calendar.current.date(byAdding: .day, value: 3, to: Date.now) ?? Date.now,
            eventType: Emoji.work.rawValue,
            addList: false,
            addTime: true,
            addHours: true,
            addMinutes: true,
            addSeconds: true
        ),
        Event(
            title: "Movie Night",
            eventColor: "118AB2",
            dayOfEvent: Calendar.current.date(byAdding: .day, value: 1, to: Date.now) ?? Date.now,
            eventType: Emoji.entertainment.rawValue,
            addList: false,
            addTime: true,
            addHours: true,
            addMinutes: true,
            addSeconds: true
        ),
        Event(
            title: "New Year",
            eventColor: "073B4C",
            dayOfEvent: Calendar.current.date(byAdding: .day, value: 100, to: Date.now) ?? Date.now,
            eventType: Emoji.holiday.rawValue,
            addList: false,
            addTime: true,
            addHours: true,
            addMinutes: true,
            addSeconds: true
        )
    ]
}

enum Emoji: String, CaseIterable {
    case vacation = "🏝️"
    case birthday = "🎂"
    case work = "✈️"
    case entertainment = "🍿"
    case holiday = "📆"
    case other = "⏰"
    
    var description: String {
        switch self {
        case .vacation:
            "Vacation"
        case .birthday:
            "Birthday"
        case .work:
            "Work Trip"
        case .entertainment:
            "Entertainment"
        case .holiday:
            "Holiday"
        case .other:
            "Other"
        }
    }
}

