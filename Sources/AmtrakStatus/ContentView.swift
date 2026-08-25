import SwiftCrossUI
import Foundation


struct ContentView: View {
    @State var client = AmtrakClient()

    @State var stationCode = "ASD" // Ashland, VA
    @State var rows: [TrainStatusRow] = []
    @State var isLoading = false
    @State var errorMessage: String?
    @State var currentStation: String = ""
    @State var localTimeZone: TimeZone?
    
    let amtrakDate = AmtrakDateFormatting()
    let unknown = "Unknown"

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

            var newRows: [TrainStatusRow] = []
            for number in lookup.trainNumbers {
                let trains = try await client.fetchAllTrainStatus(num: number)
                for train in trains {
                    let platform = train.stations?.first(
                        where: { $0.code == code
                        },
                    )?.platform
                    await newRows
                        .append(
                            trainStatus(
                                for: train,
                                atStationCode: code,
                                timeZone: lookup.timeZone,
                                zoneCache: &zoneCache
                            )
                        )
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
    
    func isOnTime(arr: String?, schArr: String?) -> TrainLateness {
       
        guard
            let actualDate = amtrakDate.parsedDate(from: arr),
            let scheduledDate = amtrakDate.parsedDate(from: schArr)
        else {
            return .unknown
        }
        
        let differenceInMinutes = Int(actualDate.timeIntervalSince(scheduledDate) / 60)
        
        switch differenceInMinutes {
        case -1...1:
            return .onTime
        case ..<0:
            return .early(minutes: -differenceInMinutes)
        default:
            return .late(minutes: differenceInMinutes)
        }
    }
    
    func trainStatus(
        for train: Train,
        atStationCode code: String,
        timeZone: TimeZone?,
        zoneCache: inout [String: TimeZone?]
    ) async -> TrainStatusRow {
        let leg = train.stations?.first { $0.code == code }
        let stationName = leg?.name ?? unknown
        let track = leg?.platform ?? ""
        
        var originZone: TimeZone?
        if let orgCode = train.origCode {
            originZone = await fetchTimeZone(
                forStationCode: orgCode,
                cache: &zoneCache
            )
        }
        
        let time = amtrakDate.time(
            from: leg?.arr,
            timeZone: timeZone,
            relativeTo: originZone
        ) ?? amtrakDate.time(
            from: leg?.schArr,
            timeZone: timeZone,
            relativeTo: originZone
        )
        
        currentStation = stationName
        localTimeZone = timeZone
        
        return TrainStatusRow(
            trainID: train.trainID,
            time: time ?? "",
            trainNum: train.trainNum,
            presence: leg?.status ?? .unknown, // Yeah... It's a little confusing
            train: train.routeName,
            to: train.destName,
            from: train.origName,
            status: isOnTime(
                arr: leg?.arr,
                schArr: leg?.schArr
            ),
            track: track.isEmpty ? "" : track
        )
    }
    
    func fetchTimeZone(forStationCode code: String, cache: inout [String: TimeZone?]) async -> TimeZone? {
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
