//
// Created by David Kanenwisher on 7/8/21.
//

import simd

extension float4x4 {
    static func scaleX(_ scalar: Float) -> float4x4 {
        float4x4(
                [scalar, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    static func perspectiveProjection() -> float4x4 {
        matrix_identity_float4x4
    }
}
