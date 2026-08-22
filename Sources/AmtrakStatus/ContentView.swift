import SwiftCrossUI

struct ContentView: View {
    @State var client = AmtrakClient()

    @State var stationCode = "ASD" // Ashland, VA
    @State var rows: [TrainStatusRow] = []
    @State var isLoading = false
    @State var errorMessage: String?

    var body: some View {
        VStack {
            HStack {
                Text("Station Code:")
                TextField("e.g. ASD", text: $stationCode)
                    .frame(width: 100)

                Button("Refresh") {
                    Task {
                        await loadTrainStatus(forStationCode: normalizedStationCode)
                    }
                }.disabled(normalizedStationCode.isEmpty || isLoading)
            }.padding(10)
            
            // Most popular Virtual Railfan stations
            HStack {
                Button("Ashland, VA")
                {
                    Task {
                        await loadTrainStatus(forStationCode: "ASD")
                    }
                }
                
                Button("San Juan Capistrano, CA")
                {
                    Task {
                        await loadTrainStatus(forStationCode: "SNC")
                    }
                }
                
                Button("La Plata, MO")
                {
                    Task {
                        await loadTrainStatus(forStationCode: "LAP")
                    }
                }
            }

        
            Table(rows) {
                TableColumn("Number", value: \TrainStatusRow.trainNum)
                TableColumn("Route", value: \TrainStatusRow.routeName)
                TableColumn("On Time", value: \TrainStatusRow.onTime)
                TableColumn("Platform", value: \TrainStatusRow.platform)

            }.overlay(alignment: .bottomTrailing) {
                if isLoading {
                    ProgressView()
                        .padding(10)
                }
            }
            
            HStack {
                if let errorMessage {
                    Text(errorMessage)
                }
            }.padding(10)
            
        }.padding()
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
                    newRows.append(TrainStatusRow(
                        trainID: train.trainID,
                        trainNum: train.trainNum,
                        routeName: train.routeName,
                        onTime: train.trainTimely.isEmpty ? "" : train.trainTimely,
                        platform: (
                            platform?.isEmpty == false,
                        ) ? platform! : "",
                    ))
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
}
