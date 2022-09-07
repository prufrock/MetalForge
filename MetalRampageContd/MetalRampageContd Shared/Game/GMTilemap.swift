//
// Created by David Kanenwisher on 12/26/21.
//

struct GMTilemap {
    private(set) var tiles: [GMTile]
    // Things needs to able to change because they can be generated
    // It can't be  because then the size of the array could change unexpectedly.
    private var things: [GMThing]
    let width: Int

    // for switching between levels
    let index: Int

    init(_ map: GMMapData, index: Int) {
        tiles = map.tiles
        things = map.things ?? Array(repeating: .nothing, count: map.tiles.count)
        width = map.width
        self.index = index
    }
}

struct GMMapData: Decodable {
    fileprivate let tiles: [GMTile]
    fileprivate let things: [GMThing]? // If things aren't provided they are generated.
    fileprivate let width: Int

    // These are all optionals so the level designer can decide whether they should be generated.
    // These specify how many to place.
    let monsters: Int?
    let monsterBlobs: Int?
    let healingPotions: Int?
    let fireBlasts: Int?
    let pushWalls: Int?

    // Allow the seed to be configured
    let seed: UInt64?
}

extension GMTilemap {
    var height: Int {
        return tiles.count / width
    }

    var size: Float2 {
        return Float2(x: Float(width), y: Float(height))
    }

    subscript(x: Int, y: Int) -> GMTile {
        get { tiles[y * width + x] }
        set { tiles[y * width + x] = newValue}
    }

    /**
     Access things via subscript so it's a little more natural to get at them.
     Also, it's 1D array posing as a 2D array so hide that.
     */
    subscript(thing x: Int, y: Int) -> GMThing {
        get { things[y * width + x]}
        set { things[y * width + x] = newValue}
    }

    func tile(at position: Float2, from direction: Float2) -> GMTile {
        var offsetX = 0, offsetY = 0
        // If either component is a whole number, use the direction
        // to determine which side should be checked.
        if position.x.rounded(.down) == position.x {
            offsetX = direction.x > 0 ? 0 : -1
        }
        if position.y.rounded(.down) == position.y {
            offsetY = direction.y > 0 ? 0 : -1
        }
        return self[Int(position.x) + offsetX, Int(position.y) + offsetY]
    }

    func closestFloorTile(to x: Int, _ y: Int) -> GMTile? {
        // search for a floor tile(not wall) by searching in the immediate vicinity for a
        // floor tile to use otherwise give up.
        for y in max(0, y - 1) ... min(height - 1, y + 1) {
            for x in max(0, x - 1) ... min(width - 1, x + 1) {
                let tile = self[x, y]
                if tile.isWall == false {
                    return tile
                }
            }
        }
        return nil
    }

    func hitTest(_ ray: GMRay) -> Float2 {
        var position = ray.origin
        let slope = ray.direction.x / ray.direction.y
        repeat {
            let edgeDistanceX, edgeDistanceY: Float
            // Find the distance to the edge of the current tile
            if ray.direction.x > 0 {
                edgeDistanceX = position.x.rounded(.down) + 1 - position.x
            } else {
                edgeDistanceX = position.x.rounded(.up) - 1 - position.x
            }
            if ray.direction.y > 0 {
                edgeDistanceY = position.y.rounded(.down) + 1 - position.y
            } else {
                edgeDistanceY = position.y.rounded(.up) - 1 - position.y
            }

            //Find the position that the ray exits the tile.
            let step1 = Float2(edgeDistanceX, edgeDistanceX / slope)
            let step2 = Float2(edgeDistanceY * slope, edgeDistanceY)

            if step1.length < step2.length {
                position += step1
            } else {
                position += step2
            }
        } while tile(at: position, from: ray.direction).isWall == false
        return position
    }
}
