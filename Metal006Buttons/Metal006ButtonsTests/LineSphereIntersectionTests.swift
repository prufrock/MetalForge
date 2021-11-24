//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd

class LineSphereIntersectionTests: XCTestCase {

    func testIntersects() throws {
        let sphere = Sphere(center: SIMD3<Float>(5,0,0), radius: 0.1)
        let ray = Ray(origin: SIMD3<Float>(0,0,0), target: SIMD3<Float>(5.0, 0.0, 0.0))

        XCTAssertTrue(ray.intersects(with: sphere))
    }

    func testDoesntIntersect() throws {
        let sphere = Sphere(center: SIMD3<Float>(5,0,0), radius: 0.1)
        let ray = Ray(origin: SIMD3<Float>(0,0,0), target: SIMD3<Float>(5.0, 3.0, 0.0))

        XCTAssertFalse(ray.intersects(with: sphere))
    }
}

struct Sphere {
    let center: SIMD3<Float>
    let radius: Float
}

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