//
// Created by David Kanenwisher on 12/20/21.
//

public struct World {
    public let map: Tilemap
    public var player: Player

    public init(map: Tilemap) {
        self.map = map
        self.player = Player(position: map.size / 2)
    }
}

public extension World {
    var size: Float2 { map.size }

    mutating func update(timeStep: Float) {
        player.position += player.velocity * timeStep
        player.position.x.formTruncatingRemainder(dividingBy: size.x - 1)
        player.position.y.formTruncatingRemainder(dividingBy: size.y - 1)
    }
}
