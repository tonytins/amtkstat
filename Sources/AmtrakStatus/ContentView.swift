import SwiftCrossUI

struct ContentView: View {
    @State var client = AmtrakClient()
    
    @State var stationCode = "ASD" // Ashville, VA
    @State var rows: [TrainStatusRow] = []
    @State var isLoading = false
    @State var errorMessage: String?
    
    var body: some View {
        
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
            
        }
    }
}
