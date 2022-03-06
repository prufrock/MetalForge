//
// Created by David Kanenwisher on 12/26/21.
//

public struct Tilemap: Decodable {
    private let tiles: [Tile]
    public let things: [Thing]
    public let width: Int
}

public extension Tilemap {
    var height: Int {
        return tiles.count / width
    }

    var size: Float2 {
        return Float2(x: Float(width), y: Float(height))
    }

    subscript(x: Int, y: Int) -> Tile {
       tiles[y * width + x]
    }

    func tile(at position: Float2, from direction: Float2) -> Tile {
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

    func hitTest(_ ray: Ray) -> Float2 {
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
