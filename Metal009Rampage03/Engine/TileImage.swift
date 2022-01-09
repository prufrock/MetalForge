//
// Created by David Kanenwisher on 12/18/21.
//

import simd
import MetalKit

struct TileImage {
    var tiles: [([Float3], Float4x4, Color, MTLPrimitiveType)]
    private let size = Float(1.0)
    private let start = Float(0.0)
    private let tile1: [Float3]
    private let tile2: [Float3]
    private let tile3: [Float3]
    private let tile4: [Float3]
    private let tile5: [Float3]

    init(map: Tilemap, wallColor: Color = .white) {
        tile1 = [
            Float3(0.0, 1.0, 0.0),
            Float3(1.0, 1.0, 0.0),
            Float3(1.0, 0.0, 0.0),

            Float3(1.0, 0.0, 0.0),
            Float3(0.0, 0.0, 0.0),
            Float3(0.0, 1.0, 0.0),
        ]

        tile2 = [
            Float3(0.0, 0.0, 0.0),
            Float3(0.0, 0.0, 1.0),
            Float3(1.0, 0.0, 0.0),

            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 0.0, 0.0),
            Float3(1.0, 0.0, 1.0),
        ]

        tile3 = [
            Float3(1.0, 0.0, 0.0),
            Float3(1.0, 0.0, 1.0),
            Float3(1.0, 1.0, 1.0),

            Float3(1.0, 1.0, 1.0),
            Float3(1.0, 1.0, 0.0),
            Float3(1.0, 0.0, 0.0),
        ]

        tile4 = [
            Float3(0.0, 1.0, 0.0),
            Float3(0.0, 1.0, 1.0),
            Float3(1.0, 1.0, 1.0),

            Float3(1.0, 1.0, 1.0),
            Float3(1.0, 1.0, 0.0),
            Float3(0.0, 1.0, 0.0),
        ]

        tile5 = [
            Float3(0.0, 0.0, 0.0),
            Float3(0.0, 1.0, 0.0),
            Float3(0.0, 1.0, 1.0),

            Float3(0.0, 0.0, 0.0),
            Float3(0.0, 0.0, 1.0),
            Float3(0.0, 1.0, 0.0),
        ]

            tiles = [(tile1, matrix_identity_float4x4, .white, .triangle)]

        var myTiles: [([Float3], Float4x4, Color, MTLPrimitiveType)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), wallColor, .triangle))
                    myTiles.append((tile2, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), .blue, .triangle))
                    myTiles.append((tile3, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), .green, .triangle))
                    myTiles.append((tile4, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), .red, .triangle))
                    myTiles.append((tile5, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), .grey, .triangle))
                }
            }
        }

        tiles = myTiles
    }
}
