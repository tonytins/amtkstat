import Foundation

struct TrainAlert: Codable {
    var message: String
}

struct Station: Codable, Sendable {
    var name: String
    var code: String
    var tz: String
    var bus: Bool
    var schArr: String
    var schDep: String
    var arr: String
    var dep: String
    var arrCmnt: String
    var depCmnt: String
    var status: StationStatus
    var stopIconColor: String
    var platform: String
}

enum StationStatus: String, Codable, Sendable {
    case enroute = "Enroute"
    case station = "Station"
    case departed = "Departed"
    case unknown = "Unknown"
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = StationStatus(rawValue: rawValue) ?? .unknown
    }
}

struct Train: Codable {
    var routeName: String
    var trainNum: String
    var trainNumRaw: String?
    var trainID: String
    var lat: Double?
    var lon: Double?
    var trainTimely: String?
    var iconColor: String?
    var textColor: String?
    var heading: String?
    var eventCode: String?
    var eventTZ: String?
    var eventName: String?
    var origCode: String?
    var origName: String
    var destCode: String?
    var destName: String
    var trainState: String?
    var velocity: Double?
    var statusMsg: String?
    var createdAt: String?
    var updatedAt: String?
    var lastValTS: String?
    var objectID: Int?
    var provider: String?
    var providerShort: String?
    var onlyOfTrainNum: Bool?
    var alerts: [TrainAlert]?
    var stations: [Station]?
}

struct StationMeta: Codable {
    var name: String
    var code: String
    var tz: String?
    var lat: Double?
    var lon: Double?
    var hasAddress: Bool?
    var address1: String?
    var address2: String?
    var city: String?
    var state: String?
    var zip: String?
    var trains: [String]
}

struct StaleData: Codable {
    var avgLastUpdate: Double
    var activeTrains: Int
    var stale: Bool
}

typealias TrainResponse = [String: [Train]]
typealias StationResponse = [String: StationMeta]

struct TrainStatusRow: Identifiable {
    var id: String {
        trainID
    }
    
    var trainID: String
    var trainNum: String
    var routeName: String
    var status: String
    var platform: String
    var arrival: String
    var departure: String
    var origin: String
    var destination: String
    // var serviceDate: String
}
