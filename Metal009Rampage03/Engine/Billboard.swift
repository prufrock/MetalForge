//
// Created by David Kanenwisher on 2/19/22.
//

public struct Billboard {
    public var start: Float2
    public var direction: Float2
    public var length: Float

    public init(start: Float2, direction: Float2, length: Float) {
        self.start = start
        self.direction = direction
        self.length = length
    }
}

public extension Billboard {
    var end: Float2 {
        start + direction * length
    }
}