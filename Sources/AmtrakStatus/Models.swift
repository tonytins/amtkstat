import Foundation

struct TrainAlert: Codable {
    var message: String
}

struct Station: Codable {
    var code: String
    var platform: String?
}

struct Train: Codable {
    var routeName: String
    var trainNum: String
    var trainNumRaw: String
    var trainID: String
    var lat: Double
    var lon: Double
    var trainTimely: String
    var iconColor: String?
    var textColor: String?
    var heading: String?
    var eventCode: String?
    var eventTZ: String?
    var eventName: String?
    var origCode: String?
    var origName: String?
    var destCode: String?
    var destName: String?
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
    var id: String { trainID }

    var trainID: String
    var trainNum: String
    var routeName: String
    var onTime: String
    var platform: String
}
