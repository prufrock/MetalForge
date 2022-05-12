//
// Created by David Kanenwisher on 5/9/22.
//

/**
 Knows how to create random levels.
 */
struct MapGenerator {
    private(set) var map: Tilemap
    // keep track of the players starting position
    // this makes it so we can adjust the level around them
    private var playerPosition: Float2!
    private var emptyTiles: [Float2] = []
    private var wallTiles: Set<Float2> = []

    public init(mapData: MapData, index: Int) {
        map = Tilemap(mapData, index: index)

        // Find empty tiles
        // Find them in a systematic way so we don't have to sit around all day waiting
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                // the 0.5 offsets are so it's in the middle of the tile.
                let position = Float2(x: Float(x) + 0.5, y: Float(y) + 0.5)
                if map[x, y].isWall {
                    // only elevator back walls can be switches
                    if map[x, y] == .elevatorBackWall {
                        map[thing: x, y] = .switch
                    }
                    // keep track of the walls for push walls
                    wallTiles.insert(position)
                } else {
                    // it's not a wall!
                    switch map[thing: x, y] {
                    case .nothing:
                        // it's nothing! put it in the bag!
                        emptyTiles.append(position)
                    case .player:
                        // it's the player so keep track of that!
                        playerPosition = position
                    default:
                        break
                    }
                }
            }
        }

        // Add doors
        for position in emptyTiles {
            let x = Int(position.x), y = Int(position.y)
            let left = map[x - 1, y], right = map[x + 1, y],
                up = map[x, y - 1], down = map[x, y + 1]
            // look for matching walls either up and below the tile
            // or left and right of the tile
            if (left.isWall && right.isWall && !up.isWall && !down.isWall)
                || (!left.isWall && !right.isWall && up.isWall && down.isWall) {
                add(.door, at: position)
            }
        }

        // Add push walls
        for _ in 0 ..< (mapData.pushWalls ?? 0) {
            add(.pushWall, at: wallTiles.filter { position in
                let x = Int(position.x), y = Int(position.y)
                guard x > 0, x < map.width - 1, y > 0, y < map.height - 1 else {
                    return false // Outer wall
                }
                let left = map[x - 1, y], right = map[x + 1, y],
                    up = map[x, y - 1], down = map[x, y + 1]
                // if there's a wall to the left and right
                // not above or below
                // and there's 2 tiles above and below
                // the tile can be a push wall
                if left.isWall, right.isWall, !up.isWall, !down.isWall,
                   !map[x, y - 2].isWall, !map[x, y + 2].isWall {
                    return true
                }
                // if there's a wall above and below
                // not to the left or right
                // and there's 2 tiles to the left or right
                // the tile can be a push wall
                if !left.isWall, !right.isWall, up.isWall, down.isWall,
                   !map[x - 2, y].isWall, !map[x + 2, y].isWall {
                    return true
                }
                // the tile is viable as a push wall
                return false
            }.randomElement())
        }

        // Add monsters
        for _ in 0 ..< (mapData.monsters ?? 0) {
            add(.monster, at: emptyTiles.filter({
                        // give the player some breathing room
                        // 2.5 units of breathing room
                        (playerPosition - $0).length > 2.5
                    }).randomElement())
        }

        // Add healing potions
        for _ in 0 ..< (mapData.healingPotions ?? 0) {
            add(.healingPotion, at: emptyTiles.randomElement())
        }

        // Add fire blasts
        for _ in 0 ..< (mapData.fireBlasts ?? 0) {
            add(.fireBlast, at: emptyTiles.randomElement())
        }
    }
}

private extension MapGenerator {
    mutating func add(_ thing: Thing, at position: Float2?) {
        if let position = position {
            // put the thing there
            map[thing: Int(position.x), Int(position.y)] = thing
            // remove the tile that was used
            // this way a different thing isn't placed there
            if let index = emptyTiles.lastIndex(of: position) {
                emptyTiles.remove(at: index)
            }
        }
    }
}
