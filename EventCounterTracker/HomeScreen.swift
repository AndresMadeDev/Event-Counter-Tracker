//
//  HomeScreen.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Query(sort: \Event.dayOfEvent) var events: [Event]
    @State private var sampleEvents: [Event] = Event.samples
    @Environment(\.modelContext) var modelContext
    @State private var showCreateEvent: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(events) { event in
                    VStack {
                        NavigationLink {
                           EventDetailScreen(event: event)
                        } label: {
                            EventListCellView(event: event)
                        }
                        .padding(.horizontal)
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 10)
                    .containerRelativeFrame(.vertical, alignment: .center)
                }
            }
            .padding(.top)
            .ignoresSafeArea(.all)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("You have \(events.count) events")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreateEvent, content: {
                NavigationStack {
                    CreateEventScreen()
                }
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Create Event") {
                        showCreateEvent.toggle()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.accentColor)
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
}
