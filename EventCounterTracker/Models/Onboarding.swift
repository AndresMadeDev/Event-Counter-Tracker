//
//  Onboarding.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import Foundation
import SwiftUI


struct Onboarding: Identifiable, Equatable {
    let id: UUID = UUID()
    var title: String
    var message: String
    var page: Int
    
    static var samplePages: [Onboarding] = [
        Onboarding(title: "Event Counter Tracker",
                   message: "Keep track of our upcoming event with a countdown timer",
                   page: 0),
        
        Onboarding(title: "Event Counter Tracker",
                   message: "Add a checklist for your upcoming event",
                   page: 1),
        
        Onboarding(title: "Event Counter Tracker",
                   message: "Add unlimited events.",
                   page: 2),
    ]
}
