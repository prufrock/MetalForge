//
// Created by David Kanenwisher on 12/14/21.
//

import simd

typealias Int2 = SIMD2<Int>

typealias Float2 = SIMD2<Float>
typealias Float3 = SIMD3<Float>
typealias Float4 = SIMD4<Float>

typealias Float2x2 = simd_float2x2
typealias Float3x3 = simd_float3x3
typealias Float4x4 = simd_float4x4

extension Float {
    func roundDown() -> Int {
        var value = self
        value.round(.down)
        return Int(value)
    }
}

extension Float4x4 {
    static func identity() -> Self {
        matrix_identity_float4x4
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

    static func scale(x: Float, y: Float, z: Float) -> Self {
        Self(
            [x, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1]
        )
    }

    func scaledBy(x: Float, y: Float, z: Float) -> Self {
        self * Self.scale(x: x, y: y, z: z)
    }

    static func scaleX(_ x: Float) -> Self {
        Self(
            [x, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }

    func scaledX(by x: Float) -> Self {
        self * Self.scaleX(x)
    }

    static func scaleY(_ y: Float) -> Self {
        Self(
            [1, 0, 0, 0],
            [0, y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        )
    }

    func scaledY(by y: Float) -> Self {
        self * Self.scaleY(y)
    }

    static func scaleZ(_ z: Float) -> Self {
        Self(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, z, 0],
            [0, 0, 0, 1]
        )
    }

    func scaledZ(by z: Float) -> Self {
        self * Self.scaleZ(z)
    }

    static func rotateX(_ angle: Float) -> Self {
         Self(
            [1,           0,          0, 0],
            [0,  cos(angle), sin(angle), 0],
            [0, -sin(angle), cos(angle), 0],
            [0,           0,          0, 1]
        )
    }

    static func rotateY(_ angle: Float) -> Self {
        Self(
            [cos(angle), 0, -sin(angle), 0],
            [         0, 1,           0, 0],
            [sin(angle), 0,  cos(angle), 0],
            [         0, 0,           0, 1]
        )
    }

    static func rotateZ(_ angle: Float) -> Self {
        Self(
            [ cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        )
    }

    static func translate(x: Float, y: Float, z: Float) -> Self {
        Self(
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [x, y, z, 1]
        )
    }
}

extension Float3 {
    func toFloat2() -> Float2 {
        Float2(x: x, y: y)
    }
}

extension Float3x3 {
    static func scale(x: Float, y: Float, z: Float = 1.0) -> Self {
        Self(
            [x, 0, 0],
            [0, y, 0],
            [0, 0, z]
        )
    }

    func scaledBy(x: Float, y: Float, z: Float) -> Self {
        self * Self.scale(x: x, y: y, z: z)
    }

    static func translate(x: Float, y: Float, z: Float = 1.0) -> Self {
        Self(
            [1, 0, 0],
            [0, 1, 0],
            [x, y, z]
        )
    }
}

extension Float2x2 {
    static func rotate(_ angle: Float) -> Self {
        Self(
            [ cos(angle), sin(angle)],
            [-sin(angle), cos(angle)]
        )
    }

    static func rotate(sine: Float, cosine: Float) -> Self {
        Self(
            [ cosine, sine],
            [-sine, cosine]
        )
    }

    static func scale(x: Float, y: Float) -> Self {
        Self(
            [x, 0],
            [0, y]
        )
    }

    func scaledBy(x: Float, y: Float) -> Self {
        self * Self.scale(x: x, y: y)
    }
}

extension Float2 {
    var length : Float {
        (x * x + y * y).squareRoot()
    }

    var orthogonal: Self {
        Float2(x: -y, y: x)
    }

    init(_ x: Int, _ y: Int) {
        self.init(Float(x), Float(y))
    }

    internal func toFloat3() -> Float3 {
        Float3(self)
    }

    func rotated(by rotation: Float2x2) -> Self {
        rotation * self
    }

    func toTranslation() -> Float4x4 {
        Float4x4.translate(x: x, y: y, z: 0.0)
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

struct PhysicalConstants {
    static let speedOfSoundMetersPerSecond: Float = 343.0
}
