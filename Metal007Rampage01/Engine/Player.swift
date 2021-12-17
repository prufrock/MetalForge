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

public extension Player {
    mutating func update(timeStep: Float) {
        position += velocity * Float2(timeStep, timeStep)
        position.x.formTruncatingRemainder(dividingBy: 8)
        position.y.formTruncatingRemainder(dividingBy: 8)
    }
}
