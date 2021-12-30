//
// Created by David Kanenwisher on 12/18/21.
//

import simd
import MetalKit

struct TileImage {
    var tiles: [([Float3], Float4x4, Color, MTLPrimitiveType)]
    private let size = Float(1.0)
    private let start = Float(0.0)
    private let tile: [Float3]

    init(map: Tilemap, wallColor: Color = .white) {
        tile = [
            Float3(start + size * 0, start + size * 1, 0.0),
            Float3(start + size * 1, start + size * 1, 0.0),
            Float3(start + size * 1, start + size * 0, 0.0),

            Float3(start + size * 1, start + size * 0, 0.0),
            Float3(start + size * 0, start + size * 0, 0.0),
            Float3(start + size * 0, start + size * 1, 0.0),
        ]

        tiles = [(tile, matrix_identity_float4x4, .white, .triangle)]

        var myTiles: [([Float3], Float4x4, Color, MTLPrimitiveType)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    myTiles.append((tile, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), wallColor, .triangle))
                }
            }
        }

        tiles = myTiles
    }
}
