//
// Created by David Kanenwisher on 11/24/21.
//

import simd

struct GMRay {
    let origin: float3
    let target: float3
    var displacement: float3 {
        get {
            target - origin
        }
    }

    func intersects(with sphere: GMSphere) -> Bool {
        //discriminant
        let a = simd_dot(displacement, displacement)
        let b = 2.0 * simd_dot((origin - sphere.center), displacement)
        let oc = origin - sphere.center
        let c = simd_dot(oc, oc) - (sphere.radius * sphere.radius)

        return discriminant(a: a, b: b, c: c) >= 0
    }

    private func discriminant(a: Float, b: Float, c: Float) -> Float {
        (b * b) - 4 * a * c
    }
}
