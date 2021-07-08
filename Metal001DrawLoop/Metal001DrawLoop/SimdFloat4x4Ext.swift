//
// Created by David Kanenwisher on 7/7/21.
//

import simd

extension simd_float4x4 {
    static func scaleX(_ scalar: Float) -> simd_float4x4 {
        float4x4(
                [scalar, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }
}