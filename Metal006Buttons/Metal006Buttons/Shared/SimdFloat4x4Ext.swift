//
//  SimdFloat4x4Ext.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import simd

extension float4x4 {
    static func scaleX(_ scalar: GMFloat) -> float4x4 {
        float4x4(
                [scalar, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    static func scaleY(_ scalar: GMFloat) -> float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, scalar, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    static func perspectiveProjection(nearPlane: GMFloat, farPlane: GMFloat) -> float4x4 {
        float4x4(
                [GMFloat(tan(Double.pi / 5)), 0, 0, 0],
                [0, GMFloat(tan(Double.pi / 5)), 0, 0],
                [0, 0, 1, 1],
                [0, 0, 0, 1]
        )
    }

    static func translate(x: GMFloat, y: GMFloat, z: GMFloat) -> float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [x, y, z, 1]
        )
    }
}
