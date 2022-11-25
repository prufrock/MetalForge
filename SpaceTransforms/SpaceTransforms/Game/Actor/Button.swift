//
//  Wall.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//


import simd

struct Button: Actor {
    var radius: Float = 0.5
    var position: MF2 = MF2(space: .world, value: F2(0.0, 0.0))
    var model: BasicModels

    var color: Float3 = Float3(0.0, 0.5, 1.0)

    var modelToUpright:Float4x4 {
        get {
            Float4x4.identity()
        }
    }

    var uprightToWorld:Float4x4 {
        get {
            Float4x4.translate(x: position.value.x, y: position.value.y, z: 0.0) *
            Float4x4.scale(x: radius, y: radius, z: radius)
        }
    }
}
