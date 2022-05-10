//
// Created by David Kanenwisher on 5/9/22.
//

/**
 Knows how to create random levels.
 */
struct MapGenerator {
    private(set) var map: Tilemap

    public init(mapData: MapData, index: Int) {
        map = Tilemap(mapData, index: index)

        // Find empty tiles
        // Find them in a systematic way so we don't have to sit around all day waiting
        var emptyTiles = Set<Float2>()
        // keep track of the players starting position
        // this makes it so we can adjust the level around them
        var playerPosition: Float2!
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                // the 0.5 offsets are so it's in the middle of the tile.
                let position = Float2(x: Float(x) + 0.5, y: Float(y) + 0.5)
                if map[x, y].isWall == false {
                    // it's not a wall!
                    switch map[thing: x, y] {
                    case .nothing:
                        // it's nothing! put it in the bag!
                        emptyTiles.insert(position)
                    case .player:
                        // it's the player so keep track of that!
                        playerPosition = position
                    default:
                        break
                    }
                }
            }
        }

        // Add monsters
        for _ in 0 ..< (mapData.monsters ?? 0) {
            if let position = emptyTiles.filter({
                    // give the player some breathing room
                    // 2.5 units of breathing room
                    (playerPosition - $0).length > 2.5
                }).randomElement() {
                // The position
                let x = Int(position.x), y = Int(position.y)
                // this position is no a monster!
                map[thing: x, y] = .monster
                // Don't let the tile be used again
                emptyTiles.remove(position)
            }
        }

        // Add healing potions
        for _ in 0 ..< (mapData.healingPotions ?? 0) {
            if let position = emptyTiles.randomElement() {
                let x = Int(position.x), y = Int(position.y)
                map[thing: x, y] = .healingPotion
                emptyTiles.remove(position)
            }
        }

        // Add fire blasts
        for _ in 0 ..< (mapData.fireBlasts ?? 0) {
            if let position = emptyTiles.randomElement() {
                let x = Int(position.x), y = Int(position.y)
                map[thing: x, y] = .fireBlast
                emptyTiles.remove(position)
            }
        }
    }
}
