import XCTest
@testable import Amortized

// MARK: - PaymentService Tests

final class PaymentServiceTests: XCTestCase {

    func testMonthlyPayment_30Year_7Percent() {
        // $300k, 30yr, 7% → ~$1,995.91
        let result = PaymentService.shared.calculateMonthlyPayment(
            amount: 300_000, downPayment: 0, term: 30, interestRate: 7.0
        )
        XCTAssertEqual(result, 1995.91, accuracy: 0.5)
    }

    func testMonthlyPayment_downPaymentReducesPrincipal() {
        // $400k - $100k down = same principal as $300k loan
        let result = PaymentService.shared.calculateMonthlyPayment(
            amount: 400_000, downPayment: 100_000, term: 30, interestRate: 7.0
        )
        XCTAssertEqual(result, 1995.91, accuracy: 0.5)
    }

    func testMonthlyPayment_15Year_6Point5Percent() {
        // $300k, 15yr, 6.5% → ~$2,613.32
        let result = PaymentService.shared.calculateMonthlyPayment(
            amount: 300_000, downPayment: 0, term: 15, interestRate: 6.5
        )
        XCTAssertEqual(result, 2613.32, accuracy: 0.5)
    }

    func testMonthlyPayment_zeroRate_producesNaNOrInfinite() {
        // PMT formula has rate in the denominator; 0% → undefined
        let result = PaymentService.shared.calculateMonthlyPayment(
            amount: 200_000, downPayment: 0, term: 30, interestRate: 0
        )
        XCTAssertTrue(result.isNaN || result.isInfinite)
    }

    func testMonthlyPayment_zeroInputs_producesNaN() {
        let result = PaymentService.shared.calculateMonthlyPayment(
            amount: 0, downPayment: 0, term: 0, interestRate: 0
        )
        XCTAssertTrue(result.isNaN)
    }
}

// MARK: - FRED JSON Parsing Tests

final class FREDParsingTests: XCTestCase {

    func testFREDResponseDecoding() throws {
        let json = """
        {
            "observations": [
                {"date": "2024-01-11", "value": "6.66"},
                {"date": "2024-01-04", "value": "6.62"}
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(FREDResponse.self, from: json)
        XCTAssertEqual(response.observations.count, 2)
        XCTAssertEqual(response.observations[0].date, "2024-01-11")
        XCTAssertEqual(response.observations[0].value, "6.66")
        XCTAssertEqual(response.observations[1].date, "2024-01-04")
        XCTAssertEqual(response.observations[1].value, "6.62")
    }

    func testRatesFormatting_validValues() {
        let rates = Rates(thirtyYearFixed: "6.66", fifteenYearFixed: "6.02", fiveOneARM: "6.31")
        XCTAssertEqual(rates.thirtyYearFixed, "6.66%")
        XCTAssertEqual(rates.fifteenYearFixed, "6.02%")
        XCTAssertEqual(rates.fiveOneARM, "6.31%")
    }

    func testRatesFormatting_invalidValueFallsBackToZero() {
        let rates = Rates(thirtyYearFixed: "invalid", fifteenYearFixed: "", fiveOneARM: "6.31")
        XCTAssertEqual(rates.thirtyYearFixed, "0.00%")
        XCTAssertEqual(rates.fifteenYearFixed, "0.00%")
        XCTAssertEqual(rates.fiveOneARM, "6.31%")
    }

    func testRatesFormatting_padsToTwoDecimalPlaces() {
        let rates = Rates(thirtyYearFixed: "6.1", fifteenYearFixed: "6", fiveOneARM: "6.5")
        XCTAssertEqual(rates.thirtyYearFixed, "6.10%")
        XCTAssertEqual(rates.fifteenYearFixed, "6.00%")
        XCTAssertEqual(rates.fiveOneARM, "6.50%")
    }
}

// MARK: - PaymentViewModel Tests

@MainActor
final class PaymentViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = PaymentViewModel()
        XCTAssertEqual(vm.amount, "")
        XCTAssertEqual(vm.downPayment, "")
        XCTAssertEqual(vm.interestRate, "")
        XCTAssertEqual(vm.term, "")
        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertFalse(vm.soundOn)
    }

    func testCalculate_validInputs_producesFormattedPayment() {
        let vm = PaymentViewModel()
        vm.amount = "300000"
        vm.downPayment = "0"
        vm.interestRate = "7.0"
        vm.term = "30"
        vm.calculate()

        let result = Float(vm.paymentAmount)
        XCTAssertNotNil(result, "paymentAmount should be a parseable number")
        XCTAssertEqual(result!, 1995.91, accuracy: 0.5)
    }

    func testCalculate_emptyInputs_showsErrorMessage() {
        let vm = PaymentViewModel()
        vm.calculate()
        XCTAssertEqual(vm.paymentAmount, "You must enter all required fields.")
    }

    func testCalculate_missingRateAndTerm_showsErrorMessage() {
        let vm = PaymentViewModel()
        vm.amount = "300000"
        // rate and term default to 0 → PMT formula yields NaN
        vm.calculate()
        XCTAssertEqual(vm.paymentAmount, "You must enter all required fields.")
    }

    func testClear_resetsAllFields() {
        let vm = PaymentViewModel()
        vm.amount = "300000"
        vm.downPayment = "60000"
        vm.interestRate = "7.0"
        vm.term = "30"
        vm.paymentAmount = "1800.00"
        vm.clear()

        XCTAssertEqual(vm.amount, "")
        XCTAssertEqual(vm.downPayment, "")
        XCTAssertEqual(vm.interestRate, "")
        XCTAssertEqual(vm.term, "")
        XCTAssertEqual(vm.paymentAmount, "0.00")
    }

    func testToggleSound_flipsState() {
        let vm = PaymentViewModel()
        XCTAssertFalse(vm.soundOn)
        vm.toggleSound()
        XCTAssertTrue(vm.soundOn)
        vm.toggleSound()
        XCTAssertFalse(vm.soundOn)
    }
}

// MARK: - RatesViewModel Tests

@MainActor
final class RatesViewModelTests: XCTestCase {

    func testInitialState_ratesAreNil() {
        let vm = RatesViewModel()
        XCTAssertNil(vm.todayRates)
        XCTAssertNil(vm.lastWeekRates)
    }
}
