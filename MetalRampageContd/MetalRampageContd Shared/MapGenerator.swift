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
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall == false, map[thing: x, y] == .nothing {
                    // if it's not a wall and it's "nothing" then put in the bag of empties.
                    // this allows selecting empty tiles in constant time
                    emptyTiles.insert(Float2(x: Float(x) + 0.5, y: Float(y) + 0.5))
                }
            }
        }

        // Add monsters
        for _ in 0 ..< (mapData.monsters ?? 0) {
            if let position = emptyTiles.randomElement() {
                let x = Int(position.x), y = Int(position.y)
                map[thing: x, y] = .monster
                emptyTiles.remove(position)
            }
        }
    }
}
