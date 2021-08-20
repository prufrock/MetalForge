# MCLCModel

Models the operations and data being performed by the MatrixCaLCulator.

A scetch in test of where I think this will go as I put it together.
```swift
import XCTest
@testable import MCLCModel

final class MCLCModelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MCLCModel().text, "Hello, World!")

        var model = MCLCModel(
            vector: MCLCVector
            vectorInput: MCLCVectorInput
            matrixInput: MCLCMatrixInput
            matrix: MCLCMatrix
            history: MCLCHistory
        )

        var snapshot = model.snapshot

        snapshot.current.vector[0]
        snapshot.current.vector[1]
        snapshot.current.vector[2]

        snapshot.history.hasBack()
        snapshot.history.hasForward()
    }

    func testInitializeModel() {
        let model = MCLCModel(

        )

        let snapshot = model.snapshot

        XCTAssertEqual({Range(0..<4).map{_ in 0.0}}(), snapshot.vector)
        XCTAssertEqual("", snapshot.vectorInput)

        XCTAssertEqual({Range(0..<16).map{_ in 0.0}}(), snapshot.matrix)
        XCTAssertEqual("", snapshot.matrixInput)

        XCTAssertFalse(snapshot.history.hasBack())
        XCTAssertFalse(snapshot.history.hasForward())
        XCTAssertEqual(snapshot, snapshot.history.current())
    }

    func testComputeDotProduct() {
        let matrix = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
        let originalVector = [1.0, 2.0, 3.0, 1.0]
        let resultVector = [1.0, 2.0, 4.0, 1.0]

        var model = MCLCModel(
            vector: MCLCVector = originalVector
            vectorInput: MCLCVectorInput = ""
            matrixInput: MCLCMatrixInput = ""
            matrix: MCLCMatrix = matrix
            history: MCLCHistory
        )

        model = model.update(command: MCLCComputeDotProduct)
        var snapshot = model.snapshot

        XCTAssertEqual(resultVector, snapshot.vector)
        XCTAssertEqual("", snapshot.vectorInput)

        XCTAssertEqual(matrix, snapshot.matrix)
        XCTAssertEqual("", snapshot.matrixInput)

        XCTAssertTrue(snapshot.history.hasBack())
        XCTAssertFalse(snapshot.history.hasForward())
        XCTAssertEqual(snapshot, snapshot.history.current())

        model = model.update(command: MCLCUndo)
        snapshot = model.snapshot


        XCTAssertEqual(originalVector, snapshot.vector)
        XCTAssertEqual("", snapshot.vectorInput)

        XCTAssertEqual(matrix, snapshot.matrix)
        XCTAssertEqual("", snapshot.matrixInput)

        XCTAssertFalse(snapshot.history.hasBack())
        XCTAssertTrue(snapshot.history.hasForward())
        XCTAssertEqual(snapshot, snapshot.history.current())

        model = model.update(command: MCLCRedo)
        snapshot = model.snapshot

        XCTAssertEqual(resultVector, snapshot.vector)
        XCTAssertEqual("", snapshot.vectorInput)

        XCTAssertEqual(matrix, snapshot.matrix)
        XCTAssertEqual("", snapshot.matrixInput)

        XCTAssertTrue(snapshot.history.hasBack())
        XCTAssertFalse(snapshot.history.hasForward())
        XCTAssertEqual(snapshot, snapshot.history.current())
    }
}
```
