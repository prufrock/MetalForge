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
}