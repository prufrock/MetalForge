//
// Created by David Kanenwisher on 12/18/21.
//

import Foundation
import simd

struct TileImage {
    var tiles: [([Float4], Float4x4, Color)]
    private let tile = [
        Float4(-0.5, 0.5, 0.0, 1.0),
        Float4(0.5, 0.5, 0.0, 1.0),
        Float4(0.5, -0.5, 0.0, 1.0),

        Float4(0.5, -0.5, 0.0, 1.0),
        Float4(-0.5, -0.5, 0.0, 1.0),
        Float4(-0.5, 0.5, 0.0, 1.0),
    ]

    init(bitmap: Bitmap, pixelSize: Float = 1.0) {
        tiles = [(tile, matrix_identity_float4x4, .white)]

        var myTiles: [([Float4], Float4x4, Color)] = []
        for y in 0 ..< bitmap.height {
            for x in 0 ..< bitmap.width {
                myTiles.append((tile, Float4x4.init(translateX: Float(x), y: Float(-y), z: 0), bitmap[x,y]))
            }
        }

        tiles = myTiles
    }
}
