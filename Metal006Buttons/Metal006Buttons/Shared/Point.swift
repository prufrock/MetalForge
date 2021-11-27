//
//  Point.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Foundation

struct Point {
    let rawValue: float3

    init(rawValue: float3) {
        self.rawValue = rawValue
    }

    init(_ x: GMFloat, _ y: GMFloat, _ z: GMFloat) {
        rawValue = [x, y, z]
    }

    static func origin() -> Point {
        Point(0.0, 0.0, 0.0)
    }

    func translate(_ x: GMFloat, _ y: GMFloat, _ z: GMFloat) -> Point {
        Self(
            self.rawValue.x + x,
            self.rawValue.y + y,
            self.rawValue.z + z
        )
    }
}
