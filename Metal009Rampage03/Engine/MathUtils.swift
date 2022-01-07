//
// Created by David Kanenwisher on 12/14/21.
//

import simd

public typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>
typealias Float4 = SIMD4<Float>

public typealias Float2x2 = simd_float2x2
public typealias Float4x4 = simd_float4x4

public extension Float4x4 {
    internal static func identity() -> Float4x4 {
        matrix_identity_float4x4
    }

    static func perspectiveProjection(nearPlane: Float, farPlane: Float) -> Float4x4 {
        float4x4(
            [Float(tan(Double.pi / 5)), 0, 0, 0],
            [0, Float(tan(Double.pi / 5)), 0, 0],
            [0, 0, 1, 1],
            [0, 0, 0, 1]
        )
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

    init(rotateZ angle: Float) {
        self.init(
            [ cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
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

public extension Float2x2 {
    init(rotate angle: Float) {
        self.init(
            [ cos(angle), sin(angle)],
            [-sin(angle), cos(angle)]
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

    func rotated(by rotation: Float2x2) -> Float2 {
        rotation * self
    }
}

extension Float3 {
    init(_ value: Float2) {
        self.init(value.x, value.y, 0.0)
    }
}
