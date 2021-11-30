//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd
@testable import Metal006Buttons

class LineSphereIntersectionTests: XCTestCase {

    func testIntersects() throws {
        let sphere = GMSphere(center: float3(5,0,0), radius: 0.1)
        let ray = GMRay(origin: float3(0,0,0), target: float3(5.0, 0.0, 0.0))

        XCTAssertTrue(ray.intersects(with: sphere))
    }

    func testDoesntIntersect() throws {
        let sphere = GMSphere(center: float3(5,0,0), radius: 0.1)
        let ray = GMRay(origin: float3(0,0,0), target: float3(5.0, 3.0, 0.0))

        XCTAssertFalse(ray.intersects(with: sphere))
    }
}