import XCTest
@testable import Amortized

// MARK: - Report Formatter Tests

final class ReportFormatterTests: XCTestCase {

    func testPercentFormatsWholePercentInput() {
        XCTAssertEqual(ReportFormatters.percent(6.41), "6.41%")
    }
}

// MARK: - PaymentService Tests

final class PaymentServiceTests: XCTestCase {

    private let fixedStartDate = Date(timeIntervalSince1970: 1_704_067_200)

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

    func testExtraPaymentImprovesPayoffAndTotals() throws {
        let standard = PaymentService.shared.buildAmortizationSchedule(
            loanAmount: 300_000,
            annualRate: 7,
            loanPeriodYears: 30,
            paymentsPerYear: 12,
            startDate: fixedStartDate,
            extraPayment: 0
        )
        let accelerated = PaymentService.shared.buildAmortizationSchedule(
            loanAmount: 300_000,
            annualRate: 7,
            loanPeriodYears: 30,
            paymentsPerYear: 12,
            startDate: fixedStartDate,
            extraPayment: 250
        )

        let standardPayoff = try XCTUnwrap(standard.summary.payoffDate)
        let acceleratedPayoff = try XCTUnwrap(accelerated.summary.payoffDate)

        XCTAssertLessThan(accelerated.summary.actualNumberOfPayments, standard.summary.actualNumberOfPayments)
        XCTAssertLessThan(acceleratedPayoff, standardPayoff)
        XCTAssertLessThan(accelerated.summary.totalInterest, standard.summary.totalInterest)
        XCTAssertLessThan(accelerated.summary.totalPaid, standard.summary.totalPaid)
        XCTAssertGreaterThan(accelerated.summary.totalEarlyPayments, 0)
    }

    func testFinalPaymentDoesNotOverpayRemainingBalance() throws {
        let result = PaymentService.shared.buildAmortizationSchedule(
            loanAmount: 300_000,
            annualRate: 7,
            loanPeriodYears: 30,
            paymentsPerYear: 12,
            startDate: fixedStartDate,
            extraPayment: 10_000
        )
        let finalPayment = try XCTUnwrap(result.schedule.last)

        XCTAssertEqual(finalPayment.principal, finalPayment.beginningBalance, accuracy: 0.001)
        XCTAssertEqual(
            finalPayment.totalPayment,
            finalPayment.beginningBalance + finalPayment.interest,
            accuracy: 0.001
        )
        XCTAssertEqual(finalPayment.endingBalance, 0, accuracy: 0.001)
    }

    func testSummaryTotalPaidMatchesActualSchedulePayments() {
        let result = PaymentService.shared.buildAmortizationSchedule(
            loanAmount: 240_000,
            annualRate: 6.41,
            loanPeriodYears: 30,
            paymentsPerYear: 12,
            startDate: fixedStartDate,
            extraPayment: 175
        )
        let scheduleTotal = result.schedule.reduce(0) { $0 + $1.totalPayment }

        XCTAssertFalse(result.schedule.isEmpty)
        XCTAssertEqual(result.summary.totalPaid, scheduleTotal, accuracy: 0.001)
    }

    func testSummaryPayoffDateMatchesLastScheduleEntry() throws {
        let result = PaymentService.shared.buildAmortizationSchedule(
            loanAmount: 240_000,
            annualRate: 6.41,
            loanPeriodYears: 30,
            paymentsPerYear: 12,
            startDate: fixedStartDate,
            extraPayment: 175
        )

        XCTAssertEqual(result.summary.payoffDate, try XCTUnwrap(result.schedule.last).paymentDate)
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
        XCTAssertEqual(vm.extraPayment, "")
        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertTrue(vm.paymentSchedule.isEmpty)
        XCTAssertNil(vm.amortizationSummary)
        XCTAssertNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)
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
        XCTAssertFalse(vm.paymentSchedule.isEmpty)
        XCTAssertNotNil(vm.amortizationSummary)
        XCTAssertTrue(vm.canShowReport)
    }

    func testCalculate_emptyInputs_showsErrorMessage() {
        let vm = PaymentViewModel()
        vm.calculate()
        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertNotNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)
    }

    func testCalculate_missingRateAndTerm_showsErrorMessage() {
        let vm = PaymentViewModel()
        vm.amount = "300000"
        vm.calculate()
        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertNotNil(vm.validationMessage)
        XCTAssertTrue(vm.paymentSchedule.isEmpty)
        XCTAssertNil(vm.amortizationSummary)
    }

    func testClear_resetsAllFields() {
        let vm = PaymentViewModel()
        let defaultStartDate = vm.startDate
        configureValidLoan(vm)
        vm.extraPayment = "200"
        vm.calculate()
        XCTAssertTrue(vm.canShowReport)

        vm.validationMessage = "Old validation"
        vm.startDate = Date(timeIntervalSince1970: 1_800_000_000)
        vm.clear()

        XCTAssertEqual(vm.amount, "")
        XCTAssertEqual(vm.downPayment, "")
        XCTAssertEqual(vm.interestRate, "")
        XCTAssertEqual(vm.term, "")
        XCTAssertEqual(vm.extraPayment, "")
        XCTAssertEqual(vm.startDate, defaultStartDate)
        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertTrue(vm.paymentSchedule.isEmpty)
        XCTAssertNil(vm.amortizationSummary)
        XCTAssertNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)
    }

    func testEditingInputInvalidatesExistingResultsImmediately() {
        let vm = PaymentViewModel()
        configureValidLoan(vm)
        vm.calculate()
        XCTAssertTrue(vm.canShowReport)

        vm.amount = ""

        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertTrue(vm.paymentSchedule.isEmpty)
        XCTAssertNil(vm.amortizationSummary)
        XCTAssertFalse(vm.canShowReport)

        vm.calculate()
        XCTAssertNotNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)
    }

    func testDownPaymentGreaterThanLoanAmountIsRejected() {
        let vm = PaymentViewModel()
        configureValidLoan(vm)
        vm.downPayment = "300001"

        vm.calculate()

        XCTAssertEqual(vm.validationMessage, "Down payment must be less than the loan amount.")
        XCTAssertEqual(vm.paymentAmount, "0.00")
        XCTAssertFalse(vm.canShowReport)
    }

    func testNegativeInputsAreRejected() {
        let vm = PaymentViewModel()
        configureValidLoan(vm)
        vm.downPayment = "-1"
        vm.calculate()
        XCTAssertEqual(vm.validationMessage, "Down payment cannot be negative.")
        XCTAssertFalse(vm.canShowReport)

        configureValidLoan(vm)
        vm.extraPayment = "-1"
        vm.calculate()
        XCTAssertEqual(vm.validationMessage, "Extra payment cannot be negative.")
        XCTAssertFalse(vm.canShowReport)

        configureValidLoan(vm)
        vm.amount = "-300000"
        vm.calculate()
        XCTAssertNotNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)

        configureValidLoan(vm)
        vm.interestRate = "-7"
        vm.calculate()
        XCTAssertNotNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)

        configureValidLoan(vm)
        vm.term = "-30"
        vm.calculate()
        XCTAssertNotNil(vm.validationMessage)
        XCTAssertFalse(vm.canShowReport)
    }

    func testScheduleUnavailableBeforeValidCalculation() {
        let vm = PaymentViewModel()
        XCTAssertFalse(vm.canShowReport)

        configureValidLoan(vm)
        XCTAssertFalse(vm.canShowReport)

        vm.calculate()
        XCTAssertTrue(vm.canShowReport)
    }

    func testToggleSound_flipsState() {
        let vm = PaymentViewModel()
        XCTAssertFalse(vm.soundOn)
        vm.toggleSound()
        XCTAssertTrue(vm.soundOn)
        vm.toggleSound()
        XCTAssertFalse(vm.soundOn)
    }

    private func configureValidLoan(_ vm: PaymentViewModel) {
        vm.amount = "300000"
        vm.downPayment = "0"
        vm.interestRate = "7.0"
        vm.term = "30"
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
