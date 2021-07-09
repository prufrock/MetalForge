//
// Created by David Kanenwisher on 7/8/21.
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
