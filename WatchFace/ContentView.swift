//
//  ContentView.swift
//  WatchFace
//
//  Created by Kraig Kistler on 4/8/23.
//  Copyright © 2023 Kraig Kistler. All rights reserved.
//  https://www.youtube.com/watch?v=dxxCPdcMcFw
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AnalogClock(clockSize: 150)
            
            AnalogClock(clockSize: 200)
            
            AnalogClock(clockSize: 300)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - CurrentDateView
struct CurrentDateView: View {
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(dateString(date: currentDate))
            .onReceive(timer) { _ in
                currentDate = Date()
            }
    }
    
    private func dateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        return formatter.string(from: date)
        
    }
}

// MARK: - AnalogClock
struct AnalogClock: View {
    @State private var currentTime = Time()
    let timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    var clockSize: CGFloat = 300
    
    var body: some View {
        let scaleFactor = clockSize / 300
        
        return ZStack {
            // Watchface outer circle
            Circle()
                .strokeBorder(.orange, lineWidth: 1 * scaleFactor)
                .shadow(radius: 1)
                .frame(width: 230 * scaleFactor, height: 230 * scaleFactor)
            // Watchface hours
            ForEach(1..<13) { hour in
                Text("\(hour)")
                    .foregroundColor(.primary)
                    .font(.system(size: 15 * scaleFactor))
                    .position(getPositionForHour(hour, scaleFactor: scaleFactor))
            }
            // Watchface dots
            ForEach(0..<60) { dot in
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 2 * scaleFactor, height: 2 * scaleFactor)
                    .offset(y: -90 * scaleFactor)
                    .rotationEffect(.degrees(Double(dot) * 6))
            }
            // Watchface ticks
            ForEach(0..<60) { tick in
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: (tick % 5 == 0 ? 2 : 1) * scaleFactor, height: (tick % 5 == 0 ? 15 : 7) * scaleFactor)
                    .offset(y: -75 * scaleFactor)
                    .rotationEffect(.degrees(Double(tick) * 6))
            }
            // Watchface hands
            HourHand(scaleFactor: scaleFactor)
                .rotationEffect(.degrees(Double(currentTime.hour * 30) + Double(currentTime.minute) / 2))
            MinuteHand(scaleFactor: scaleFactor)
                .rotationEffect(.degrees(Double(currentTime.minute * 6)))
            SecondHand(scaleFactor: scaleFactor)
                .rotationEffect(.degrees(Double(currentTime.second * 6)))
            InnerCircle(scaleFactor: scaleFactor)
            // Watchface inner circle
            CurrentDateView()
                .font(.system(size: 10 * scaleFactor)).bold()
                .foregroundColor(.orange)
                .offset(y: 40 * scaleFactor)
        }
        .frame(width: clockSize, height: clockSize)
        .onReceive(timer) { input in
            currentTime = Time()
        }
    }
    
    // MARK: - Helper Functions
    private func getPositionForHour(_ hour: Int, scaleFactor: CGFloat) -> CGPoint {
        let hourAngle: Double
        if hour == 12 {
            hourAngle = -90 // Adjust for 12 o'clock position
        } else {
            hourAngle = Double(hour) * 30 - 90
        }
        let hourRadians = hourAngle * Double.pi / 180
        let x = 100 * scaleFactor * cos(hourRadians)
        let y = 100 * scaleFactor * sin(hourRadians)
        return CGPoint(x: x + 150 * scaleFactor, y: y + 150 * scaleFactor)
    }
}

// MARK: - Time
struct Time {
    let hour: Int
    let minute: Int
    let second: Int
    
    init() {
        let calendar = Calendar.current
        let now = Date()
        self.hour = calendar.component(.hour, from: now) % 12
        self.minute = calendar.component(.minute, from: now)
        self.second = calendar.component(.second, from: now)
    }
}

// MARK: - HourHand
struct HourHand: View {
    var scaleFactor: CGFloat
    
    var body: some View {
        Capsule()
            .fill(Color.primary)
            .frame(width: 4 * scaleFactor, height: 30 * scaleFactor)
            .offset(y: -30 * scaleFactor)
        Rectangle()
            .fill(Color.primary)
            .frame(width: 1 * scaleFactor, height: 40 * scaleFactor)
            .offset(y: -25 * scaleFactor)
    }
}

// MARK: - MinuteHand
struct MinuteHand: View {
    var scaleFactor: CGFloat
    
    var body: some View {
        Capsule()
            .fill(Color.primary)
            .frame(width: 4 * scaleFactor, height: 50 * scaleFactor)
            .offset(y: -40 * scaleFactor)
        Rectangle()
            .frame(width: 1 * scaleFactor, height: 55 * scaleFactor)
            .offset(y: -32 * scaleFactor)
    }
}

// MARK: - SecondHand
struct SecondHand: View {
    var scaleFactor: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.orange)
            .frame(width: 1 * scaleFactor, height: 60 * scaleFactor)
            .offset(y: -35 * scaleFactor)
    }
}

// MARK: - InnerCircle
struct InnerCircle: View {
    var scaleFactor: CGFloat
    
    var body: some View{
        Circle()
            .strokeBorder(.orange, lineWidth: 1 * scaleFactor)
            .frame(width: 10 * scaleFactor)
    }
}
