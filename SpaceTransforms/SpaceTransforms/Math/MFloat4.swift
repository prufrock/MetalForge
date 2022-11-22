//
//  MFloat4.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/16/22.
//

import Foundation
import simd


typealias Float4 = SIMD4<Float>

typealias Float4x4 = simd_float4x4

extension Float4x4 {
    static func identity() -> Self {
        matrix_identity_float4x4
    }

    static func translate(x: Float, y: Float, z: Float) -> Self {
        Self(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [x, y, z, 1]
        )
    }

    static func translate(_ mf2: MF2) -> Self {
        Self(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [mf2.value.x, mf2.value.x, 1, 1]
        )
    }

    static func scale(x: Float, y: Float, z: Float) -> Self {
        Self(
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1]
        )
    }

    static func perspectiveProjection(fov: Float, aspect: Float, nearPlane: Float, farPlane: Float) -> Self {
        let zoom = 1 / tan(fov / 2) // objects get smaller as fov increases

        let y = zoom
        let x = y / aspect
        let z = farPlane / (farPlane - nearPlane)
        let w = -nearPlane * z
        let X = Float4(x, 0, 0, 0)
        let Y = Float4(0, y, 0, 0)
        let Z = Float4(0, 0, z, 1)
        let W = Float4(0, 0, w, 0)

        return Self(X, Y, Z, W)
    }
}
