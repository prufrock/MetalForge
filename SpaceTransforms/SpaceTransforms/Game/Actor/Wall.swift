//
//  Wall.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//


import simd

struct Wall: Actor {
    var position: MF2 = MF2(space: .world, value: F2(0.0, 0.0))
    var model: BasicModels

    var color: Float3 = Float3(0.0, 0.0, 1.0)

    var modelToUpright:Float4x4 {
        get {
            Float4x4.identity()
        }
    }

    var uprightToWorld:Float4x4 {
        get {
            Float4x4.translate(x: position.value.x, y: position.value.y, z: 0.0) *
            Float4x4.scale(x: 0.5, y: 0.5, z: 0.5)
        }
    }
}
