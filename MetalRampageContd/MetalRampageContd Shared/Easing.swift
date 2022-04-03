//
// Created by David Kanenwisher on 3/24/22.
//

import Foundation

enum Easing {}

extension Easing {
    static func linear(_ t: Float, a: Float = 1.0) -> Float {
        min(a, t)
    }

    static func easeIn(_ t: Float, a: Float = 1.0) -> Float {
        min(a, t * t)
    }

    static func easeOut(_ t: Float, a: Float = 1.0) -> Float {
        min(a, 1 - easeIn(1 - t))
    }

    static func easeInEaseOut(_ t: Float, a: Float = 1.0) -> Float {
        if t < 0.5 {
            return 2 * easeIn(t)
        } else {
            return 4 * t - 2 * easeIn(t) - 1
        }
    }
}