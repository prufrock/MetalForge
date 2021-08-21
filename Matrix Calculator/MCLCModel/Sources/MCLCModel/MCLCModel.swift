struct MCLCSingleWindowModel: MCLCModel {
    let vectorInput: MatrixInput = MatrixInput("")
    let matrixInput: MatrixInput = MatrixInput("")
    let vector: [Float] = [0.0, 0.0, 0.0, 0.0]

    public func snapshot() -> MCLCModel {
        return self
    }
}

protocol MCLCModel {
    var vectorInput: MatrixInput { get }
    var matrixInput: MatrixInput { get }
    var vector: [Float] { get } // eventually double, decimal, or a generic that can be any of those.

    func snapshot() -> MCLCModel
}

func mclcModel() -> MCLCModel {
    MCLCSingleWindowModel()
}

struct MatrixInput: RawRepresentable {
    var rawValue: String

    typealias RawValue = String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
