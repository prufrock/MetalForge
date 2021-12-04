//
//  Point.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

struct Point {
    let rawValue: Float3

    init(rawValue: Float3) {
        self.rawValue = rawValue
    }

    init(_ x: Float, _ y: Float, _ z: Float) {
        rawValue = [x, y, z]
    }

    static func origin() -> Point {
        Point(0.0, 0.0, 0.0)
    }

    func translate(_ x: Float, _ y: Float, _ z: Float) -> Point {
        Self(
            self.rawValue.x + x,
            self.rawValue.y + y,
            self.rawValue.z + z
        )
    }
}
