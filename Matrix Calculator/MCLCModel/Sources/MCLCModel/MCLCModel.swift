struct MCLCSingleWindowModel: MCLCModel {
    let vectorInput: MatrixInput = MatrixInput("")

    public func snapshot() -> MCLCModel {
        return self
    }
}

protocol MCLCModel {
    var vectorInput: MatrixInput { get }

    func snapshot() -> MCLCModel
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
