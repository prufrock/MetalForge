struct MCLCSingleWindowModel: MCLCModel {
    let vectorInput: MatrixInput = MatrixInput("")
    let matrixInput: MatrixInput = MatrixInput("")

    public func snapshot() -> MCLCModel {
        return self
    }
}

protocol MCLCModel {
    var vectorInput: MatrixInput { get }
    var matrixInput: MatrixInput { get }

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
