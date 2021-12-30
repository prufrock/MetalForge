//
// Created by David Kanenwisher on 12/14/21.
//

import simd

public typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>
typealias Float4 = SIMD4<Float>

typealias Float4x4 = simd_float4x4

extension Float4x4 {
    static func identity() -> Float4x4 {
        matrix_identity_float4x4
    }

    init(scaleX x: Float, y: Float, z: Float) {
        self.init(
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1]
        )
    }

    init(scaleY y: Float) {
        self.init(
            [1, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }

    init(translateX x: Float, y: Float, z: Float) {
        self.init(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [x, y, z, 1]
        )
    }
}

public extension Float2 {
    var length : Float {
        (x * x + y * y).squareRoot()
    }

    var orthogonal: Float2 {
        return Float2(x: -y, y: x)
    }

    internal func toFloat3() -> Float3 {
        Float3(self)
    }
}

extension Float3 {
    init(_ value: Float2) {
        self.init(value.x, value.y, 0.0)
    }
}