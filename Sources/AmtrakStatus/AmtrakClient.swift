import Foundation

enum AmtrakError: Error {
  case invalidURL(String)
  case invalidResponse
  case httpStatus(Int)
  case stationNotFound(String)
}

struct TrainStationLookUp: Sendable {
  var trainNumbers: [String]
  var timeZone: TimeZone?
}

struct AmtrakClient {
  var decoder = JSONDecoder()

  let stationBaseURL = "https://api.amtraker.com/v3/stations"
  let trainsBaseURL = "https://api.amtraker.com/v3/trains"
  let staleBaseURL = "https://api.amtraker.com/v3/stale"

  func fetchTrain(number trainid: String) async throws -> TrainResponse {
    try await get("\(trainsBaseURL)/\(trainid)")
  }

  func fetchAllTrains() async throws -> TrainResponse {
    try await get(trainsBaseURL)
  }

  func fetchStaleStatus() async throws -> StaleData {
    try await get(staleBaseURL)
  }

  func fetchAllTrainStatus(num trainNum: String) async throws -> [Train] {
    let reponse = try await fetchTrain(number: trainNum)
    return reponse.values.flatMap(\.self)
  }

  func fetchStation(code stationid: String) async throws -> StationResponse {
    try await get("\(stationBaseURL)/\(stationid)")
  }

  func fetchAllStations() async throws -> StationResponse {
    try await get(stationBaseURL)
  }

  func trainNumber(fromTrainId trainId: String) -> String {
    trainId
      .split(separator: "-")
      .first
      .map(String.init) ?? trainId
  }

  func trainStationLookup(stationCode code: String) async throws -> TrainStationLookUp {
    let reponse = try await fetchStation(code: code)

    guard let meta = reponse[code] else {
      throw AmtrakError.stationNotFound(code)
    }

    let trainNumbers = Array(Set(meta.trains.map(trainNumber(fromTrainId:))))
    let timeZone = meta.tz.flatMap(TimeZone.init(identifier:))
    return TrainStationLookUp(
      trainNumbers: trainNumbers,
      timeZone: timeZone
    )
  }

  func get<T: Decodable>(_ urlString: String) async throws -> T {
    guard let url = URL(string: urlString) else {
      throw AmtrakError.invalidURL(urlString)
    }

    let (data, reponse) = try await URLSession.shared.data(from: url)
    guard let http = reponse as? HTTPURLResponse else {
      throw AmtrakError.invalidResponse
    }

    guard (200..<300).contains(http.statusCode) else {
      throw AmtrakError.httpStatus(http.statusCode)
    }

    return try decoder.decode(T.self, from: data)
  }
}
