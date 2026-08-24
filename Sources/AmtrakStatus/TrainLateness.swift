import Foundation
import SwiftCrossUI

enum TrainLateness {
    case onTime
    case early(minutes: Int)
    case late(minutes: Int)
    case unknown
    
    var descrption: String {
        switch self {
        case .onTime:
            return "On Time"
        case .early(minutes: let minutes):
            return "\(Self.formatted(minutes)) early"
        case .late(minutes: let minutes):
            return "\(Self.formatted(minutes)) late"
        case .unknown:
            return ""
        }
    }
    
    var color: Color {
        switch self {
        case .onTime:
            return .green
        case .early:
            return .blue
        case .late:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    
    static func formatted(_  minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        guard hours > 0 else {
            return "\(minutes) mins"
        }
        return "\(hours) hr late"
    }
}
