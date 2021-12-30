//
// Created by David Kanenwisher on 12/29/21.
//

public struct Ray {
    public var origin, direction: Float2

    public init(origin: Float2, direction: Float2) {
        self.origin = origin
        self.direction = direction
    }
}
