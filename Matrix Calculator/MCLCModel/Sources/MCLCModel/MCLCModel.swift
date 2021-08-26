struct MCLCSingleWindowModel: MCLCModel {
    let vectorInput: MatrixInput = MatrixInput("")
    let matrixInput: MatrixInput = MatrixInput("")
    let vector: [[Float]]

    public init(vector: [[Float]] = [[0.0, 0.0, 0.0, 0.0]]) {
        self.vector = vector
    }

    public func snapshot() -> MCLCModel {
        return self
    }

    public func vectorAsString() -> [[String]] {
        let strings = vector[0].map { String($0) }
        return [strings]
    }
}

public protocol MCLCModel {
    var vectorInput: MatrixInput { get }
    var matrixInput: MatrixInput { get }
    var vector: [[Float]] { get } // eventually double, decimal, or a generic that can be any of those.

    func vectorAsString() -> [[String]]

    func snapshot() -> MCLCModel
}

public func mclcModel(vector: [[Float]] = [[0.0, 0.0, 0.0, 0.0]]) -> MCLCModel {
    MCLCSingleWindowModel(vector: vector)
}

public struct MatrixInput: RawRepresentable {
    public var rawValue: String

    public typealias RawValue = String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
