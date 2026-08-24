import SwiftCrossUI
import Foundation


struct ContentView: View {
    @State var client = AmtrakClient()

    @State var stationCode = "ASD" // Ashland, VA
    @State var rows: [TrainStatusRow] = []
    @State var isLoading = false
    @State var errorMessage: String?
    @State var currentStation: String = ""
    
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
                }.disabled(normalizedStationCode.isEmpty || isLoading)
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
                TableColumn("To", value: \TrainStatusRow.origin)
                TableColumn("From", value: \TrainStatusRow.destination)
                TableColumn("Status") {
                    (row: TrainStatusRow) in
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(row.status.color)
                        Text(row.status.descrption)
                            .foregroundColor(Color.white)
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
                    Text(currentStation)
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

    func loadTrainStatus(forStationCode code: String) async {
        guard !code.isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let trainNumbers = try await client.fetchStationTrainNumbers(
                stationCode: code,
            )

            guard !trainNumbers.isEmpty else {
                errorMessage = "\(code) has no trains listed right now"
                rows = []
                return
            }

            var newRows: [TrainStatusRow] = []
            for number in trainNumbers {
                let trains = try await client.fetchAllTrainStatus(num: number)
                for train in trains {
                    let platform = train.stations?.first(
                        where: { $0.code == code
                        },
                    )?.platform
                    newRows.append(trainStatus(for: train, atStationCode: code))
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
        let amtrakDate = AmtrakDateFormatting()
        
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
    
    func trainStatus(for train: Train, atStationCode code: String) -> TrainStatusRow {
        let leg = train.stations?.first { $0.code == code }
        let amtrakDate = AmtrakDateFormatting()
        let stationName = leg?.name ?? unknown
        let arrival = amtrakDate.time(from: leg?.arr) ?? amtrakDate.time(
            from: leg?.schArr
        )
        let depature = amtrakDate.time(from: leg?.dep) ?? amtrakDate.time(
            from: leg?.schDep
        )
        
        currentStation = "\(stationName) station"
        
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
