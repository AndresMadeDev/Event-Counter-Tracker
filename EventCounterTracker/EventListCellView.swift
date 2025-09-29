//
//  EventListCellView.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import SwiftUI
import Combine

struct EventListCellView: View {
    @Bindable var event: Event
    @State private var timeRemaining: TimeInterval = 0
    @State private var isEventPassed = false
    @State private var completedPercent: Double = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
            VStack(spacing: 30) {
                VStack {
                    Text(event.title)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
//                        .foregroundStyle(.primary)
                    
                    HStack {
                        Text(event.eventType)
                            .font(.headline)
                        Text(Date().formatted(.dateTime.month().day().year()))
                    }
                    .font(.title)
                    .foregroundStyle(.primary)
                }
                
                VStack {
                    HStack {
                        if event.addTime {
                            if event.dayComponents(for: Int(timeRemaining)) != "--" {
                                VStack {
                                    Text(event.dayComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 70 , weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .fontWeight(.semibold)
                                    Text("Day")
                                        .font(.title)
                                    //                                    .foregroundStyle(event.hexColor.opacity(0.6))
                                }
                                //                            .frame(height: 125)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .glassEffect(.regular.tint(event.hexColor), in: .rect(cornerRadius: 20))
                            }
                        }
                        
                        if event.addHour {
                            if event.hourComponents(for: Int(timeRemaining)) != "--" {
                                VStack {
                                    Text(event.hourComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 70 , weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .fontWeight(.semibold)
                                    
                                    Text("Hours")
                                        .font(.title)
                                    //                                    .foregroundStyle(event.hexColor.opacity(0.6))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .glassEffect(.regular.tint(event.hexColor), in: .rect(cornerRadius: 20))
                            }
                        }
                    }
                    
                    HStack {
                        if event.addMinutes {
                            if event.minutesComponents(for: Int(timeRemaining)) != "--" {
                                VStack {
                                    Text(event.minutesComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 70 , weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .fontWeight(.semibold)
                                    
                                    Text("Minutes")
                                        .font(.title)
                                    //                                    .foregroundStyle(event.hexColor.opacity(0.6))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .glassEffect(.regular.tint(event.hexColor), in: .rect(cornerRadius: 20))
                            }
                        }
                        if event.addSeconds {
                            if event.secondsComponents(for: Int(timeRemaining)) != "--" {
                                VStack {
                                    Text(event.secondsComponents(for: Int(timeRemaining)))
                                        .font(.system(size: 70 , weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.3)
                                        .fontWeight(.semibold)
                                    
                                    Text("Seconds")
                                        .font(.title)
                                    //                                    .foregroundStyle(event.hexColor.opacity(0.6))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .glassEffect(.regular.tint(event.hexColor), in: .rect(cornerRadius: 20))
                            }
                        }
                    }
                }
                
//                if event.todo?.count ?? 0 > 0 {
//                    ProgressView("\(completedPercent.formatted(.percent.precision(.fractionLength(0)))) Completed", value: completedPercent, total: 1)
//                        .animation(.easeInOut, value: completedPercent)
//                        .font(.headline)
//                        .fontWeight(.medium)
//                        .tint(.white)
//                        .padding(.vertical)
//                }
            }
            .padding()
            .padding(.bottom)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .glassEffect(.regular.tint(event.hexColor), in: .rect(cornerRadius: 10))
            .onAppear {
                updateCountdown()
                completedPercent = event.completedPercent
            }
            .onReceive(timer) { _ in
                updateCountdown()
            }
            .onChange(of: event.completedPercent) { _, newValue in
                completedPercent = newValue
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
}

#Preview {
    EventListCellView(event: Event.sample)
}
