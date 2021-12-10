//
//  SimdFloat4x4Ext.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import simd

extension Float4x4 {
    static func scaleX(_ scalar: Float) -> Float4x4 {
        float4x4(
                [scalar, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    static func scaleY(_ scalar: Float) -> Float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, scalar, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    static func perspectiveProjection(nearPlane: Float, farPlane: Float) -> Float4x4 {
        float4x4(
                [Float(tan(Double.pi / 5)), 0, 0, 0],
                [0, Float(tan(Double.pi / 5)), 0, 0],
                [0, 0, 1, 1],
                [0, 0, 0, 1]
        )
    }

    static func translate(x: Float, y: Float, z: Float) -> Float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [x, y, z, 1]
        )
    }

    static func identity() -> Float4x4 {
        matrix_identity_float4x4
    }
}
