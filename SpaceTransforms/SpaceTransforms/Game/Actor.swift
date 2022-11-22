//
//  Actor.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/19/22.
//

import Foundation

struct Actor {
    var position: MF2 = MF2(space: .world, value: F2(0.0, 0.0))
    var model: BasicModels

    var modelToUpright:Float4x4 {
        get {
            Float4x4.scale(x: 0.01, y: 0.01, z: 0.0)
        }
    }

    var uprightToWorld:Float4x4 {
        get {
            Float4x4.translate(x: position.value.x, y: position.value.y, z: 0.0)
        }
    }
}
