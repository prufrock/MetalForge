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

    static func perspectiveProjection(fov: Float, aspect: Float, nearPlane: Float, farPlane: Float) -> Float4x4 {
        let zoom = 1 / tan(fov / 2) // objects get smaller as fov increases

        let y = zoom
        let x = y / aspect
        let z = farPlane / (farPlane - nearPlane)
        let w = -nearPlane * z
        let X = Float4(x, 0, 0, 0)
        let Y = Float4(0, y, 0, 0)
        let Z = Float4(0, 0, z, 1)
        let W = Float4(0, 0, w, 0)

        return Float4x4(X, Y, Z, W)
    }

    static func scale(x: Float, y: Float, z: Float) -> Float4x4 {
        Float4x4(
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1]
        )
    }

    static func scaleX(_ x: Float) -> Float4x4 {
        Float4x4(
            [x, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }

    static func scaleY(_ y: Float) -> Float4x4 {
        Float4x4(
            [1, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }

    static func scaleZ(_ z: Float) -> Float4x4 {
        Float4x4(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1]
        )
    }

    static func rotateX(_ angle: Float) -> Float4x4 {
         Self(
            [1,           0,          0, 0],
            [0,  cos(angle), sin(angle), 0],
            [0, -sin(angle), cos(angle), 0],
            [0,           0,          0, 1]
        )
    }

    static func rotateY(_ angle: Float) -> Float4x4 {
        Self(
            [cos(angle), 0, -sin(angle), 0],
            [         0, 1,           0, 0],
            [sin(angle), 0,  cos(angle), 0],
            [         0, 0,           0, 1]
        )
    }

    static func rotateZ(_ angle: Float) -> Float4x4 {
        Self(
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

    func toTranslation() -> Float4x4 {
        Float4x4(translateX: self.x, y: self.y, z: 0.0)
    }
}

extension Float3 {
    init(_ value: Float2) {
        self.init(value.x, value.y, 0.0)
    }
}

extension Double {
    func toRadians() -> Double {
        self * (.pi / 180)
    }
}
