import XCTest
@testable import MCLCModel

final class MCLCModelTests: XCTestCase {
    func testInitialize() {
        let model = MCLCSingleWindowModel()

        XCTAssertEqual("", model.snapshot().vectorInput.rawValue)
        XCTAssertEqual("", model.snapshot().matrixInput.rawValue)
        XCTAssertEqual({[(0..<4).map{_ in Float(0.0)}]}(), model.snapshot().vector)
    }
}
