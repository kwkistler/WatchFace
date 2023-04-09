//
//  ContentView.swift
//  WatchFace
//
//  Created by Kraig Kistler on 4/8/23.
//  https://www.youtube.com/watch?v=dxxCPdcMcFw
//

/*
 
 func getAngels(for date: Date)
 // 1. Get current hout, minute, second, and nanosecond
 -> (hour: Angle, minute: Angle, second:Angle) {
 let parts = Calendar.current.dateComponents(
 [.hour, .minute, .second, .nanosecond], from: .now)
 let h = Double(parts.hour ?? 0)
 let m = Double(parts.minute ?? 0)
 let s = Double(parts.second ?? 0)
 let n = Double(parts.nanosecond ?? 0)
 
 // 2. Convert those to angle
 
 For hours 360º / 12 hours = 30º
 For minutes 360º / 60 hours = 6º
 For seconds 360º / 12 hours = 30º
 For nanoseconds 360º / 12 hours = 30º
 
 Angle = Hour x 30 + 180 // to move the houer hand straight up
 1 o'clock = 1 x 30 = 30º
 2 o'clock = 2 x 30 = 60º
 3 o'clock = 3 x 30 = 90º
            ...
 12 o'clock = 12 x 30 = 360º
 13 o'clock = 13 x 30 = 390º
 
 var hour = Angle.degrees(30 * h + 180)
 var minute = Angle.degrees(6 * m + 180)
 var second = Angle.degrees(6 * s + 180)
 
 // 3. send them back
 
 return (hour, minute, second)
 }
 
 // To get the hands width
 let width = radius / 30
 
 
 1. Get the current hand angles
 2. Figure out our drawing space
 3. Calculate some size constants
 */

import SwiftUI
import Combine

struct ClockHand: View {
    let type: ClockHandType
    let angle: AngleWrapper

    var body: some View {
        RoundedRectangle(cornerRadius: type == .second ? 2 : 4)
            .fill(type.color)
            .frame(width: type.width, height: type.height)
            .offset(y: -type.height / 2)
            .rotationEffect(angle.wrappedAngle)
            .animation(.easeInOut(duration: 0.2), value: angle)
    }
}


struct RotationAnimatableModifier: AnimatableModifier {
    var angle: Angle
    let duration: Double

    var animatableData: Double {
        get { angle.degrees }
        set { angle = Angle(degrees: newValue) }
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(angle)
            .animation(.easeInOut(duration: duration), value: angle)
    }
}

struct AngleWrapper: AdditiveArithmetic {
    var angle: Double

    init(degrees: Double) {
        self.angle = degrees.truncatingRemainder(dividingBy: 360)
    }

    static func + (lhs: AngleWrapper, rhs: AngleWrapper) -> AngleWrapper {
        return AngleWrapper(degrees: lhs.angle + rhs.angle)
    }

    static func - (lhs: AngleWrapper, rhs: AngleWrapper) -> AngleWrapper {
        return AngleWrapper(degrees: lhs.angle - rhs.angle)
    }

    static var zero: AngleWrapper {
        return AngleWrapper(degrees: 0)
    }

    var wrappedAngle: Angle {
        return Angle(degrees: angle)
    }
}



enum ClockHandType {
    case hour, minute, second

    var color: Color {
        switch self {
        case .hour, .minute:
            return .black
        case .second:
            return .red
        }
    }

    var width: CGFloat {
        switch self {
        case .hour:
            return 8
        case .minute:
            return 4
        case .second:
            return 2
        }
    }

    var height: CGFloat {
        switch self {
        case .hour:
            return 80
        case .minute:
            return 120
        case .second:
            return 140
        }
    }
}

struct AnalogClock: View {
    @State private var currentHourAngle = AngleWrapper(degrees: Time.current.hourAngle)
    @State private var currentMinuteAngle = AngleWrapper(degrees: Time.current.minuteAngle)
    @State private var currentSecondAngle = AngleWrapper(degrees: Time.current.secondAngle)

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black, lineWidth: 4)

            ForEach(0..<12) { i in
                VStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: 20)
                    Spacer()
                }
                .rotationEffect(.degrees(Double(i) * 30))
            }

            ClockHand(type: .hour, angle: currentHourAngle)
            ClockHand(type: .minute, angle: currentMinuteAngle)
            ClockHand(type: .second, angle: currentSecondAngle)
        }
        .onReceive(timer) { _ in
            let time = Time.current
            currentHourAngle = AngleWrapper(degrees: time.hourAngle)
            currentMinuteAngle = AngleWrapper(degrees: time.minuteAngle)
            currentSecondAngle = AngleWrapper(degrees: time.secondAngle)
        }
    }
}



struct CustomRotationAnimationModifier: AnimatableModifier {
    var targetAngle: Angle
    let duration: Double

    var animatableData: Angle {
        get { targetAngle }
        set { targetAngle = newValue }
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(targetAngle)
            .animation(.easeInOut(duration: duration), value: targetAngle.degrees)
    }
}


struct Time {
    let hour: Int
    let minute: Int
    let second: Int

    var hourAngle: Double {
        Double(hour % 12) * 30 + Double(minute) * 0.5
    }

    var minuteAngle: Double {
        Double(minute) * 6 + Double(second) * 0.1
    }

    var secondAngle: Double {
        Double(second) * 6
    }

    static var current: Time {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        return Time(hour: hour, minute: minute, second: second)
    }
}


struct ContentView: View {
    var body: some View {
        AnalogClock()
            .frame(width: 300, height: 300)
            .padding()
    }
}
        
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
 
 VStack {
     TimelineView(.animation) { timeline in
         Canvas { ctx, size in
             let clock = getAngels(for: timeline.date)
             let rect = CGRect(orgin: .zero, size: size)
             let r = min(size.width, size.height) / 2
             
             let border = r / 25
             let hLenght = r / 2.5
             let mLenght = r / 1.5
             
             ctx.stroke(Circle()
                 .inset(by: border / 2)
                 .path(on: rect), with: .color(.primary), lineWidth: border)
             
             ctx.translateBy(x: rect.midX, y: rect.midY)
             drawHand(in: ctx, radius: r, lenght: mLenght, angle: angles.minute)
             drawHand(in: ctx, radius: r, lenght: hLenght, angle: angles.hour)
         }
     }
 }
 .padding()
}

// 1. Get current hout, minute, second, and nanosecond
func getAngels(for date: Date)
-> (hour: Angle, minute: Angle, second:Angle) {
let parts = Calendar.current.dateComponents(
[.hour, .minute, .second, .nanosecond], from: .now)
let h = Double(parts.hour ?? 0)
let m = Double(parts.minute ?? 0)
let s = Double(parts.second ?? 0)
let n = Double(parts.nanosecond ?? 0)

var hour = Angle.degrees(30 * h + 180)
var minute = Angle.degrees(6 * m + 180)
var second = Angle.degrees(6 * s + 180)

return (hour, minute, second)
}
}

func drawHand(in context: GraphicsContext, radius: Double,
       lenght: Double, angle: Angle) {
let width = radius / 30

let stalk = Rectangle().rotation(angle, anchor: .top)
 .path(in: CGRect(x: -width / 2, y: 0, width: width, height: lenght))
context.fill(stalk, with: .color(.primary))
}

 
 */
