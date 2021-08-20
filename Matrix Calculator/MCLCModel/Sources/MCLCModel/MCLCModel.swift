struct MCLCSingleWindowModel: MCLCModel {
    var text = "Hello, World!"
    let vectorInput: String = ""

    public func snapshot() -> MCLCModel {
        return self
    }
}

protocol MCLCModel {
    var vectorInput: String { get }

    func snapshot() -> MCLCModel
}
