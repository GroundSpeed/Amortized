import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

@MainActor
final class ApiService {
    static let shared = ApiService()
    private let apiKey = "X1-ZWz1f3t3bvl4i3_1brbp"
    
    private init() {}
    
    func getRatesFromZillow() async throws -> (today: Rates, lastWeek: Rates) {
        let endpoint = "https://www.zillow.com/webservice/GetRateSummary.htm?zws-id=\(apiKey)&output=json"
        
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(RatesResponse.self, from: data)
            
            let todayRates = Rates(
                thirtyYearFixed: response.response.today.thirtyYearFixed,
                fifteenYearFixed: response.response.today.fifteenYearFixed,
                fiveOneARM: response.response.today.fiveOneARM
            )
            
            let lastWeekRates = Rates(
                thirtyYearFixed: response.response.lastWeek.thirtyYearFixed,
                fifteenYearFixed: response.response.lastWeek.fifteenYearFixed,
                fiveOneARM: response.response.lastWeek.fiveOneARM
            )
            
            return (todayRates, lastWeekRates)
        } catch let decodingError as DecodingError {
            throw APIError.decodingError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }
} 