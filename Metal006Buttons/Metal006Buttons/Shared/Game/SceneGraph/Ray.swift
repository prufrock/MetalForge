//
// Created by David Kanenwisher on 11/24/21.
//

import Foundation
import simd

struct Ray {
    let origin: SIMD3<Float>
    let target: SIMD3<Float>
    var displacement: SIMD3<Float> {
        get {
            target - origin
        }
    }

    func intersects(with sphere: Sphere) -> Bool {
        //discriminant
        let a = simd_dot(displacement, displacement)
        let b = 2.0 * simd_dot((origin - sphere.center), displacement)
        let oc = origin - sphere.center
        let c = simd_dot(oc, oc) - (sphere.radius * sphere.radius)
        let discriminant = (b * b) - 4 * a * c

        return discriminant >= 0
    }
}
