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
                TableColumn("Time", value: \TrainStatusRow.arrival)
                TableColumn("Number", value: \TrainStatusRow.trainNum)
                TableColumn("Train", value: \TrainStatusRow.routeName)
                TableColumn("To", value: \TrainStatusRow.destination)
                TableColumn("From", value: \TrainStatusRow.origin)
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
                TableColumn("Track", value: \TrainStatusRow.platform)
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
            return .black
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

            var newRows: [TrainStatusRow] = []
            for number in lookup.trainNumbers {
                let trains = try await client.fetchAllTrainStatus(num: number)
                for train in trains {
                    let platform = train.stations?.first(
                        where: { $0.code == code
                        },
                    )?.platform
                    newRows
                        .append(
                            trainStatus(
                                for: train,
                                atStationCode: code,
                                timeZone: lookup.timeZone
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
    
    func trainStatus(for train: Train, atStationCode code: String, timeZone: TimeZone?) -> TrainStatusRow {
        let leg = train.stations?.first { $0.code == code }
        let stationName = leg?.name ?? unknown
        let arrival = amtrakDate.time(from: leg?.arr, timeZone: timeZone) ?? amtrakDate.time(
            from: leg?.schArr,
            timeZone: timeZone)
        let depature = amtrakDate.time(from: leg?.dep, timeZone: timeZone) ?? amtrakDate.time(
            from: leg?.schDep,
            timeZone: timeZone)
        
        currentStation = stationName
        localTimeZone = timeZone
        
        return TrainStatusRow(
            trainID: train.trainID,
            trainNum: train.trainNum,
            routeName: train.routeName,
            status: isOnTime(arr: leg?.arr, schArr: leg?.schArr),
            platform: leg?.platform ?? "",
            arrival: arrival ?? "",
            departure: depature ?? "",
            origin: train.origName,
            destination: train.destName,
            // serviceDate: train.serviceDate
        )
    }
}
