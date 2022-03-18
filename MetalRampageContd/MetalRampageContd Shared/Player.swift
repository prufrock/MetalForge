//
// Created by David Kanenwisher on 12/16/21.
//

public struct Player: Actor {
    public var position: Float2
    public var velocity: Float2
    public let radius: Float = 0.25
    public let speed: Float = 2
    public var direction: Float2
    public var direction3d: Float4x4
    public let turningSpeed: Float = .pi/2

    public init(position: Float2) {
        self.position = position
        self.velocity = Float2(0, 0)
        self.direction = Float2(1, 0)
        self.direction3d = Float4x4.rotateY(.pi/2)
    }
}
