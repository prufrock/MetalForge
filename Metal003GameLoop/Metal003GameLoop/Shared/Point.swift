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

    init(_ x: Float, _ y: Float, _ z: Float) {
        rawValue = [x, y, z]
    }
}
