//
//  EventCounterTrackerApp.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import SwiftUI
import SwiftData

@main
struct EventCounterTrackerApp: App {
    @AppStorage("onboard") var pageIndex = 0
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.accentColor.opacity(0.9))]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.accentColor.opacity(0.9))]
       
    }
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .modelContainer(for: Event.self)
        }
    }
}
