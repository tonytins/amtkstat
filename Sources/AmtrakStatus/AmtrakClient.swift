import Foundation

enum AmtrakError: Error {
    case invalidURL(String)
    case invalidResponse
    case httpStatus(Int)
    case stationNotFound(String)
}

struct AmtrakClient {
    var decoder = JSONDecoder()
    
    let stationBaseURL = "https://api.amtraker.com/v3/stations"
    let trainsBaseURL =  "https://api.amtraker.com/v3/trains"
    let staleBaseURL = "https://api.amtraker.com/v3/stale"
    
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
