//
//  SimdFloat4x4Ext.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
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

    static func scaleY(_ scalar: Float) -> float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, scalar, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    static func perspectiveProjection(nearPlane: Float, farPlane: Float) -> float4x4 {
        float4x4(
                [(farPlane / farPlane - nearPlane), 0, 0, 0],
                [0, (farPlane / farPlane - nearPlane), 0, 0],
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
