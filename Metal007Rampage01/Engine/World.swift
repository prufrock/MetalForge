//
// Created by David Kanenwisher on 12/20/21.
//

public struct World {
    public let size: Float2
    public var player: Player

    public init() {
        self.size = Float2(8, 8)
        self.player = Player(position: Float2(4, 4))
    }
}

public extension World {
    mutating func update(timeStep: Float) {
        player.position += player.velocity * timeStep
        player.position.x.formTruncatingRemainder(dividingBy: size.x - 1)
        player.position.y.formTruncatingRemainder(dividingBy: size.y - 1)
    }
}
