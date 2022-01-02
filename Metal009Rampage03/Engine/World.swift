//
// Created by David Kanenwisher on 12/20/21.
//

public struct World {
    public let map: Tilemap
    public var player: Player!

    public init(map: Tilemap) {
        self.map = map

        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let position = Float2(x: Float(x) + 0.5, y: Float(y) + 0.5) // in the center of the tile
                let thing = map.things[y * map.width + x]
                switch thing {
                case .nothing:
                    break
                case .player:
                    self.player = Player(position: position)
                }
            }
        }
    }
}

public extension World {
    var size: Float2 { map.size }

    mutating func update(timeStep: Float, input: Input) {
        player.direction = player.direction.rotated(by: input.rotation)
        player.velocity = player.direction * Float(input.speed) * player.speed

        player.position += player.velocity * timeStep
        player.position.x.formTruncatingRemainder(dividingBy: size.x - 1)
        player.position.y.formTruncatingRemainder(dividingBy: size.y - 1)
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }
}
