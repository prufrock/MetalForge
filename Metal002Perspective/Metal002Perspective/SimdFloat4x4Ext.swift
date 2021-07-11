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

    // I figured out the problem with the perspective always being relative to the objects was because I was applying
    // my transformations in the wrong order. I still have a problem though where increasing the value of the near plane
    // moves the object closer when it should be moved further away. I'm a little bit stumped by this one and wonder if
    // I am not fully understanding how W is involved in the perspective divide.
    static func perspectiveProjection(nearPlane: Float) -> float4x4 {
        float4x4(
                [nearPlane, 0, 0, 0],
                [0, nearPlane, 0, 0],
                [0, 0, 1, 1],
                [0, 0, 0, 1]
        )
    }

    static func translate(x: Float, y: Float, z: Float) -> float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [x, y, z, 1]
        )
    }
}
