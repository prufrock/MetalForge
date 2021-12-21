//
// Created by David Kanenwisher on 12/16/21.
//

public struct Player {
    public var position: Float2
    public var velocity: Float2

    public init(position: Float2) {
        self.position = position
        self.velocity = Float2([1, 1])
    }
}