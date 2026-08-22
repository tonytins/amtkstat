import SwiftCrossUI

struct ContentView: View {
    @State var client = AmtrakClient()
    
    @State var stationCode = "ASD" // Ashville, VA
    @State var rows: [TrainStatusRow] = []
    @State var isLoading = false
    @State var errorMessage: String?
    
    var body: some View {
        HStack {
            
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
