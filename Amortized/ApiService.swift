import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

@MainActor
final class ApiService {
    static let shared = ApiService()
    private let apiKey = "8f699c2305cfba8e7459c8abd1986373"

    private init() {}

    private func fetchSeries(_ seriesId: String) async throws -> FREDResponse {
        let endpoint = "https://api.stlouisfed.org/fred/series/observations?series_id=\(seriesId)&api_key=\(apiKey)&file_type=json&sort_order=desc&limit=2"

        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(FREDResponse.self, from: data)
        } catch let decodingError as DecodingError {
            throw APIError.decodingError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }

    func getRates() async throws -> (today: Rates, lastWeek: Rates) {
        do {
            async let r30 = fetchSeries("MORTGAGE30US")
            async let r15 = fetchSeries("MORTGAGE15US")
            async let r5  = fetchSeries("MORTGAGE5US")
            let (obs30, obs15, obs5) = try await (r30, r15, r5)

            let todayRates = Rates(
                thirtyYearFixed: obs30.observations[0].value,
                fifteenYearFixed: obs15.observations[0].value,
                fiveOneARM: obs5.observations[0].value
            )

            let lastWeekRates = Rates(
                thirtyYearFixed: obs30.observations[1].value,
                fifteenYearFixed: obs15.observations[1].value,
                fiveOneARM: obs5.observations[1].value
            )

            return (todayRates, lastWeekRates)
        } catch let decodingError as DecodingError {
            throw APIError.decodingError(decodingError)
        } catch {
            throw error
        }
    }
}
