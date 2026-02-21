import Foundation

struct Rates: Codable {
    let thirtyYearFixed: String
    let fifteenYearFixed: String
    let fiveOneARM: String
    
    init(thirtyYearFixed: String, fifteenYearFixed: String, fiveOneARM: String) {
        self.thirtyYearFixed = String(format: "%.2f%%", Float(thirtyYearFixed) ?? 0)
        self.fifteenYearFixed = String(format: "%.2f%%", Float(fifteenYearFixed) ?? 0)
        self.fiveOneARM = String(format: "%.2f%%", Float(fiveOneARM) ?? 0)
    }
}

// MARK: - API Response Types
struct FREDResponse: Codable {
    let observations: [FREDObservation]
}

struct FREDObservation: Codable {
    let date: String
    let value: String
} 