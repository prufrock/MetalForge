//
// Created by David Kanenwisher on 12/14/21.
//

import simd

typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>
typealias Float4 = SIMD4<Float>

typealias Float4x4 = simd_float4x4

extension Float4x4 {
    static func identity() -> Float4x4 {
        matrix_identity_float4x4
    }
}