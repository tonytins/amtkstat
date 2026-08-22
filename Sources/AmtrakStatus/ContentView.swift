import SwiftCrossUI

struct ContentView: View {
    @State var client = AmtrakClient()
    
    @State var stationCode = "ASD" // Ashland, VA
    @State var rows: [TrainStatusRow] = []
    @State var isLoading = false
    @State var errorMessage: String?
    
    var body: some View {
        VStack {
            // TODO: Add pre-selected options in the form of buttons like the original
            HStack {
                Text("Station Code:")
                TextField("e.g. ASD", text: $stationCode)
                    .frame(width: 100)
                
                Button("Refresh")
                {
                    Task {
                        await loadTrainStatus(forStationCode: normalizedStationCode)
                    }
                }.disabled(normalizedStationCode.isEmpty || isLoading)
            }.padding(10)
            
            if let errorMessage {
                Text(errorMessage).padding(10)
            }
            
            Table(rows)
            {
                TableColumn("Number", value: \TrainStatusRow.trainNum)
                TableColumn("Number", value: \TrainStatusRow.routeName)
                TableColumn("On Time", value: \TrainStatusRow.onTime)
                TableColumn("Platform", value: \TrainStatusRow.platform)
                
            }.overlay(alignment: .bottomTrailing)
            {
                if isLoading {
                    ProgressView()
                        .padding(10)
                }
            }
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
                stationCode: code
            )
            
            guard !trainNumbers.isEmpty else {
                errorMessage = "Station \(code) has no trains listed right now"
                rows = []
                return
            }
            
            var newRows: [TrainStatusRow] = []
            for number in trainNumbers {
                // let trains = await client.fet
            }
            
        } catch AmtrakError.stationNotFound(let code)
        {
            errorMessage = "Station \(code) not foudn"
            rows = []
        } catch {
            errorMessage = "Couldn't load train status: \(error.localizedDescription)"
            rows = []
        }
    }
}
