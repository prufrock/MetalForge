//
// Created by David Kanenwisher on 12/18/21.
//

import Foundation
import simd

struct TileImage {
    var tiles: [([Float3], Float4x4, Color)]
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

        tiles = [(tile, matrix_identity_float4x4, .white)]

        var myTiles: [([Float3], Float4x4, Color)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    myTiles.append((tile, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), wallColor))
                }
            }
        }

        tiles = myTiles
    }
}
