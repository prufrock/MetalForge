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

    init(bitmap: Bitmap, pixelSize: Float = 81.0) {
        tiles = [(tile, matrix_identity_float4x4, .white)]
    }
}
