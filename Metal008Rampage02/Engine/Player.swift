//
// Created by David Kanenwisher on 12/16/21.
//

public struct Player {
    public var position: Float2
    public var velocity: Float2
    public let radius: Float = 0.5 // 0.5 a world unit
    public let speed: Float = 2

    public init(position: Float2) {
        self.position = position
        self.velocity = Float2([0, 0]) // 0, 0 world unit a second
    }
}

public extension Player {
    var rect: Rect {
        let halfSize = Float2(radius, radius)
        // the player is centered on the position
        return Rect(min: position - halfSize, max: position + halfSize)
    }
}