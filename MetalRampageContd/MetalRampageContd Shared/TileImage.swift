//
// Created by David Kanenwisher on 12/18/21.
//

import simd
import MetalKit

struct TileImage {
    var tiles: [(RNDRObject, Tile)] = []
    private let size = Float(1.0)
    private let start = Float(0.0)
    private let tile1: [Float3]
    //TODO remove texCoords and vertices. There should be some reasonable way to have a collection of objects that all
    // share the same vertices, uv, and normals but have different transforms and such.
    private let texCoords: [Float2] = [
        Float2(0.2,0.2),
        Float2(0.0,0.0),
        Float2(0.0,0.2),
        Float2(0.2,0.2),
        Float2(0.2,0.0),
        Float2(0.0,0.0)]

    /**
     Initializes a TileImage by calculating the positions of the all of the tiles in World.
     - Parameters:
       - world: The world to create tiles from.
       - wallColor: used when drawing the map or for debugging
     */
    init(world: World, wallColor: Color = .white) {
        let map = world.map
        tile1 = [
            Float3(-0.5, -0.5, -0.5),
            Float3(0.5, 0.5, -0.5),
            Float3(-0.5, 0.5, -0.5),

            Float3(-0.5, -0.5, -0.5),
            Float3(0.5, -0.5, -0.5),
            Float3(0.5, 0.5, -0.5),
        ]

        var myTiles: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Tile, Int2)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    let wallTiles = world.wallTiles(at: x, y)
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 0), wallColor, .triangle, map[x, y], Int2(x, y))) // bottom
//                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 1.0) * rotateX(.pi), .white, .triangle, map[x, y], Int2(x, y))) //top, off because it overlaps with the ceiling tiles on some tiles
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 1.0, y: Float(y), z: 1.0) * Float4x4.rotateY(.pi/2), .black, .triangle, wallTiles.east, Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 1.0, y: Float(y) + 1.0, z: 1.0) * Float4x4.rotateZ(.pi/2) * Float4x4.rotateY(.pi/2), .black, .triangle, wallTiles.north, Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 1.0) * Float4x4.rotateZ((3 * .pi)/2) * Float4x4.rotateY(.pi/2), .black, .triangle, wallTiles.south, Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y) + 1.0, z: 1.0) * Float4x4.rotateZ((2 * .pi)/2) * Float4x4.rotateY(.pi/2), .black, .triangle, wallTiles.west, Int2(x, y)))
                }
                if !map[x, y].isWall {
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 0), wallColor, .triangle, map[x, y], Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 1.0, y: Float(y), z: 1.0)  * Float4x4.rotateY(.pi), wallColor, .triangle, .ceiling, Int2(x, y)))
                }
            }
        }

        tiles = myTiles.map { vertices, uv, transform, color, primitiveType, tile, position in
            (RNDRObject(vertices: vertices, uv: uv, transform: transform, color: color, primitiveType: primitiveType, position: position), tile)
        }
    }
}
