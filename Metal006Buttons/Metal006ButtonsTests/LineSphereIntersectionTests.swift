//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd
@testable import Metal006Buttons

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