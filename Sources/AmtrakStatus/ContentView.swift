import Foundation
import SwiftCrossUI

struct ContentView: View {
  @State var client = AmtrakClient()

  @State var stationCode = "ASD"  // Ashland, VA
  @State var rows: [TrainStatusRow] = []
  @State var isLoading = false
  @State var errorMessage: String?
  @State var currentStation: String = ""
  @State var localTimeZone: TimeZone?

  let amtrakDate = AmtrakDateFormatting()
  let unknown = "Unknown"
  let staleDataThreshold: TimeInterval = 60 * 60 * 48  // 48 hours

  var body: some View {
    VStack {
      HStack {
        Text("Station Code:")
        TextField("e.g. ASD", text: $stationCode)
          .frame(width: 100)

        Button("Submit") {
          Task {
            await loadTrainStatus(forStationCode: normalizedStationCode)
          }
        }.disabled(normalizedStationCode.isEmpty)
      }.padding(10)

      // Most popular Virtual Railfan stations
      HStack {
        Button("Ashland, VA") {
          Task {
            await loadTrainStatus(forStationCode: "ASD")
          }
        }

        Button("San Juan Capistrano, CA") {
          Task {
            await loadTrainStatus(forStationCode: "SNC")
          }
        }

        Button("La Plata, MO") {
          Task {
            await loadTrainStatus(forStationCode: "LAP")
          }
        }
      }

      Table(rows) {
        TableColumn("Time", value: \TrainStatusRow.time)
        TableColumn("Number", value: \TrainStatusRow.trainNum)
        TableColumn("", value: \TrainStatusRow.presence.rawValue)
        TableColumn("Train", value: \TrainStatusRow.train)
        TableColumn("To", value: \TrainStatusRow.to)
        TableColumn("From", value: \TrainStatusRow.from)
        TableColumn("Status") {
          (row: TrainStatusRow) in
          ZStack {
            RoundedRectangle(cornerRadius: 0)
              .fill(row.status.color)
            Text(row.status.descrption)
              .foregroundColor(
                statusColour(row.status.color)
              )
          }
        }
        TableColumn("Track", value: \TrainStatusRow.track)
      }.frame(minWidth: 600)
        .overlay(alignment: .bottomTrailing) {
          if isLoading {
            ProgressView()
              .frame(alignment: .topTrailing)
              .padding(10)
          }
        }

      HStack {
        if let errorMessage {
          Text(errorMessage)
        } else if !currentStation.isEmpty {
          Text(
            "It is \(amtrakDate.localTime(timeZone: localTimeZone)) at \(currentStation) station"
          )
        }
      }.padding(10)
    }
    .frame(idealWidth: 500)
    .onAppear {
      Task {
        await loadTrainStatus(forStationCode: normalizedStationCode)
      }
    }.overlay(alignment: .topTrailing) {
      Text("Information by Amtraker")
        .padding(10)
    }
  }

  var normalizedStationCode: String {
    stationCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
  }

  func statusColour(_ color: Color) -> Color {
    switch color {
    case .green:
      return .adaptive(light: .white, dark: .black)
    default:
      return .white
    }
  }

  func loadStationStatus(forStationCode code: String) async {
    guard !code.isEmpty else {
      return
    }
  }

  func loadTrainStatus(forStationCode code: String) async {
    guard !code.isEmpty else {
      return
    }

    isLoading = true
    errorMessage = nil

    defer { isLoading = false }

    do {
      let lookup = try await client.trainStationLookup(
        stationCode: code,
      )

      guard !lookup.trainNumbers.isEmpty else {
        errorMessage = "\(code) has no trains listed right now"
        rows = []
        return
      }

      var zoneCache: [String: TimeZone?] = [code: lookup.timeZone]
      let staleness = await staleTrainLookup()

      var newRows: [TrainStatusRow] = []
      for number in lookup.trainNumbers {
        let trains = try await client.fetchAllTrainStatus(num: number)
        for train in trains {
          let platform = train.stations?.first(
            where: {
              $0.code == code
            },
          )?.platform
          let row = await trainStatus(
            for: train,
            code: code,
            zone: lookup.timeZone,
            cache: &zoneCache,
            staleness: staleness
          )
          if let row {
            newRows.append(row)
          }
        }
      }

      rows = newRows

    } catch let AmtrakError.stationNotFound(code) {
      errorMessage = "Station \(code) not found"
      rows = []
    } catch {
      errorMessage = "Couldn't load train status: \(error.localizedDescription)"
      rows = []
    }
  }

  func trainStatus(
    for train: Train,
    code stationCode: String,
    zone timeZone: TimeZone?,
    cache zoneCache: inout [String: TimeZone?],
    staleness: [String: TimeInterval]
  ) async -> TrainStatusRow? {
    let leg = train.stations?.first { $0.code == stationCode }

    guard
      !isStale(leg, timeZone: timeZone), !isDataStale(train.trainID, staleness: staleness)
    else {
      return nil
    }

    let stationName = leg?.name ?? unknown
    let track = leg?.platform ?? ""

    var originZone: TimeZone?
    if let orgCode = train.origCode {
      originZone = await fetchTimeZone(
        forStationCode: orgCode,
        cache: &zoneCache
      )
    }

    let time =
      amtrakDate.time(
        from: leg?.arr,
        in: timeZone,
        comparedTo: originZone
      )
      ?? amtrakDate.time(
        from: leg?.schArr,
        in: timeZone,
        comparedTo: originZone
      )

    if stationName != unknown {
      currentStation = stationName
      localTimeZone = timeZone
    }

    return TrainStatusRow(
      trainID: train.trainID,
      time: time ?? "",
      trainNum: train.trainNum,
      presence: leg?.status ?? .unknown,  // Yeah... It's a little confusing
      train: train.routeName,
      to: train.destName,
      from: train.origName,
      status: amtrakDate.isOnTime(
        actual: leg?.arr,
        scheduled: leg?.schArr
      ),
      track: track.isEmpty ? "" : track
    )
  }

  func isStale(_ leg: Station?, timeZone: TimeZone?) -> Bool {
    guard leg?.status == .departed else { return false }

    guard
      let deparatureDate = amtrakDate.parsedDate(
        from: leg?.dep
      ) ?? amtrakDate.parsedDate(from: leg?.schDep)
    else {
      return false
    }

    var calendar = Calendar.current
    calendar.timeZone = timeZone ?? .current
    return
      calendar
      .compare(
        deparatureDate,
        to: Date(),
        toGranularity: .day
      ) == .orderedAscending
  }

  func isDataStale(
    _ trainId: String,
    staleness: [String: TimeInterval]
  ) -> Bool {
    guard let timeSince = staleness[trainId] else { return false }
    return timeSince > staleDataThreshold
  }

  func staleTrainLookup() async -> [String: TimeInterval] {
    guard let staleData = try? await client.fetchStaleStatus() else {
      return [:]
    }
    return Dictionary(
      staleData.lastUpdatedArr.map { ($0.trainID, $0.timeSince) },
      uniquingKeysWith: { first, _ in first }
    )
  }

  func fetchTimeZone(forStationCode code: String, cache: inout [String: TimeZone?]) async
    -> TimeZone?
  {
    if let cached = cache[code] {
      return cached
    }
    let zone: TimeZone?
    do {
      let response = try await client.fetchStation(code: code)
      zone = response[code]?.tz.flatMap(TimeZone.init(identifier:))
    } catch {
      zone = nil
    }

    return zone
  }
}
