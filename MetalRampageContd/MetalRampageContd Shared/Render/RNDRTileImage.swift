//
// Created by David Kanenwisher on 12/18/21.
//

import simd
import MetalKit

struct RNDRTileImage {
    var tiles: [(RNDRObject, GMTile)] = []
    private let size = Float(1.0)
    private let start = Float(0.0)
    private let tile1: [Float3]
    //TODO remove texCoords and vertices. There should be some reasonable way to have a collection of objects that all
    // share the same vertices, uv, and normals but have different transforms and such.
    private let texCoords: [Float2] = []

    /**
     Initializes a TileImage by calculating the positions of the all of the tiles in World.
     - Parameters:
       - world: The world to create tiles from.
       - wallColor: used when drawing the map or for debugging
     */
    init(world: GMWorld, wallColor: GMColor = .white) {
        let map = world.map
        // only for the drawMap
        tile1 = [
            Float3(-0.5, -0.5, 0.0),
            Float3(-0.5, 0.5, 0.0),
            Float3(0.5, 0.5, 0.0),

            Float3(0.5, 0.5, 0.0),
            Float3(0.5, -0.5, 0.0),
            Float3(-0.5, -0.5, 0.0),
        ]

        let normals = [
            Float3(-1.5, -1.5, 0),
            Float3(-1.5, 1.5, 0),
            Float3(1.5, 1.5, 0),
            Float3(1.5, 1.5, 0),
            Float3(1.5, -1.5, 0.0),
            Float3(-1.5, -1.5, 0.0),
        ]


        let rotateTopUp = Float4x4.rotateZ(.pi/2) // rotate the object so the top is up so the texture looks correct
        //TODO make an object
        var myTiles: [([Float3], [Float2], Float4x4, GMColor, MTLPrimitiveType, GMTile, Int2, [Float3])] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    let wallTiles = world.wallTiles(at: x, y)
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 0.5, y: Float(y) + 0.5, z: 0) * Float4x4.rotateX(.pi), wallColor, .triangle, map[x, y], Int2(x, y), normals)) // bottom
//                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 1.0), .white, .triangle, map[x, y], Int2(x, y))) //top, off because it overlaps with the ceiling tiles on some tiles
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y) + 0.5, z: 0.5) * Float4x4.rotateY(.pi/2) * rotateTopUp, .black, .triangle, wallTiles.west, Int2(x, y), normals))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 1.0, y: Float(y) + 0.5, z: 0.5) * Float4x4.rotateZ((2 * .pi)/2) * Float4x4.rotateY(.pi/2) * rotateTopUp, .black, .triangle, wallTiles.east, Int2(x, y), normals))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 0.5, y: Float(y) + 1.0, z: 0.5) * Float4x4.rotateZ((3 * .pi)/2) * Float4x4.rotateY(.pi/2) * rotateTopUp, .black, .triangle, wallTiles.north, Int2(x, y), normals))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 0.5, y: Float(y), z: 0.5) * Float4x4.rotateZ(.pi/2) * Float4x4.rotateY(.pi/2) * rotateTopUp, .black, .triangle, wallTiles.south, Int2(x, y), normals))
                }
                if !map[x, y].isWall {
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 0.5, y: Float(y) + 0.5, z: 0.0) * Float4x4.rotateY(.pi), wallColor, .triangle, map[x, y], Int2(x, y), normals))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 0.5, y: Float(y) + 0.5, z: 1.0), wallColor, .triangle, .ceiling, Int2(x, y), normals))
                }
            }
        }

        tiles = myTiles.map { vertices, uv, transform, color, primitiveType, tile, position, normals in
            (RNDRObject(vertices: vertices, uv: uv, transform: transform, color: color, primitiveType: primitiveType, position: position, texture: nil, normals: normals), tile)
        }
    }
}
