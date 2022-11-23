//
//  Player.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//

import simd

struct Player: Actor {
    var position: MF2 = MF2(space: .world, value: F2(0.0, 0.0))
    var model: BasicModels
    var radius: Float = 0.125

    var color: Float3 = Float3(1.0, 0.0, 0.0)

    var modelToUpright:Float4x4 {
        get {
            Float4x4.identity()
        }
    }

    var uprightToWorld:Float4x4 {
        get {
            Float4x4.translate(x: position.value.x, y: position.value.y, z: 0.0)
            * Float4x4.scale(x: 0.125, y: 0.125, z: 0.125)
        }
    }

    /*
     A collision check where collisions are checked only so many times before simply allowing it so the game doesn't
     lock up.
     */
    mutating func avoidWalls(in world: World) {
        var attempts = 10
        while attempts > 0, let intersection = intersection(with: world) {
            position.value -= intersection
            attempts -= 1
        }
    }
}
