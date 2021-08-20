struct MCLCSingleWindowModel: MCLCModel {
    let vectorInput: String = ""

    public func snapshot() -> MCLCModel {
        return self
    }
}

protocol MCLCModel {
    var vectorInput: String { get }

    func snapshot() -> MCLCModel
}
