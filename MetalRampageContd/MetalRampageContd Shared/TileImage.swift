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

    init(world: World, wallColor: Color = .white) {
        let map = world.map
        tile1 = [
            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
            Float3(0.0, 1.0, 0.0),

            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
        ]

        var myTiles: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Tile, Int2)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    let wallTiles = world.wallTiles(at: x, y)
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 0), wallColor, .triangle, map[x, y], Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) + 1.0, y: Float(y), z: 0) * rotateY(.pi/2), .black, .triangle, wallTiles.east, Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y) + 1.0, z: 0) * rotateZ(.pi/2) * rotateY(.pi/2), .black, .triangle, wallTiles.north, Int2(x, y))) // north wall
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y) - 1.0, z: 0) * rotateZ((3 * .pi)/2) * rotateY(.pi/2), .black, .triangle, wallTiles.south, Int2(x, y))) // south wall
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x) - 1.0, y: Float(y), z: 0) * rotateZ((2 * .pi)/2) * rotateY(.pi/2), .black, .triangle, wallTiles.west, Int2(x, y)))
                }
                if !map[x, y].isWall {
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 0), wallColor, .triangle, map[x, y], Int2(x, y)))
                    myTiles.append((tile1, texCoords, Float4x4.translate(x: Float(x), y: Float(y), z: 0)  * rotateY(.pi), wallColor, .triangle, .ceiling, Int2(x, y)))
                }
            }
        }

        tiles = myTiles.map { vertices, uv, transform, color, primitiveType, tile, position in
            (RNDRObject(vertices: vertices, uv: uv, transform: transform, color: color, primitiveType: primitiveType, position: position), tile)
        }
    }

    //TODO find a home for these
    private func rotateY(_ angle: Float) -> Float4x4 {
        Float4x4.identity()
            * Float4x4.translate(x: Float(0.5), y: Float(0.5), z: 0.5)
            * Float4x4.rotateY(angle)
            * Float4x4.translate(x: -0.5, y: -0.5, z: -0.5)
    }

    private func rotateZ(_ angle: Float) -> Float4x4 {
        Float4x4.identity()
            * Float4x4.translate(x: 0.5, y: 0.5, z: 0.5)
            * Float4x4.rotateZ(angle)
            * Float4x4.translate(x: -0.5, y: -0.5, z: -0.5)
    }

    private func rotateX(_ angle: Float) -> Float4x4 {
        Float4x4.identity()
            * Float4x4.translate(x: 0.5, y: 0.5, z: 0.5)
            * Float4x4.rotateX(angle)
            * Float4x4.translate(x: -0.5, y: -0.5, z: -0.5)
    }
}
