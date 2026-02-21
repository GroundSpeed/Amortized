import SwiftUI

struct RatesView: View {
    @StateObject private var viewModel = RatesViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Today")) {
                RateRow(title: "30 Year Fixed", rate: viewModel.todayRates?.thirtyYearFixed ?? "-")
                RateRow(title: "15 Year Fixed", rate: viewModel.todayRates?.fifteenYearFixed ?? "-")
                RateRow(title: "5/1 ARM", rate: viewModel.todayRates?.fiveOneARM ?? "-")
            }
            
            Section(header: Text("Last Week"), footer: Text("Rates provided by St. Louis Fed (FRED)")) {
                RateRow(title: "30 Year Fixed", rate: viewModel.lastWeekRates?.thirtyYearFixed ?? "-")
                RateRow(title: "15 Year Fixed", rate: viewModel.lastWeekRates?.fifteenYearFixed ?? "-")
                RateRow(title: "5/1 ARM", rate: viewModel.lastWeekRates?.fiveOneARM ?? "-")
            }
        }
        .listStyle(.grouped)
        .task {
            await viewModel.loadRates()
        }
    }
}

struct RateRow: View {
    let title: String
    let rate: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 17))
            Spacer()
            Text(rate)
                .font(.custom("AvenirNext-Regular", size: 17))
                .foregroundColor(.secondary)
        }
    }
}

@MainActor
class RatesViewModel: ObservableObject {
    @Published var todayRates: Rates?
    @Published var lastWeekRates: Rates?
    
    func loadRates() async {
        do {
            let rates = try await ApiService.shared.getRates()
            todayRates = rates.today
            lastWeekRates = rates.lastWeek
        } catch {
            print("Error loading rates: \(error)")
        }
    }
} 
