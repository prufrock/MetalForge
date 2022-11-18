//
//  World.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct World {

    var vertices: [MFloat3]

    init() {
        vertices = []
        reset()
    }

    /**
     Set the world back to how it all began...
     */
    private mutating func reset() {
        vertices = [MFloat3(s: .world, v: Float3(0.0, 0.0, 0.0))]
    }

    /**
     Update the game.
     - Parameters:
       - timeStep: The amount of time to move it forward.
     */
    mutating func update(timeStep: Float) {
        vertices[0] = vertices[0] + Float3(timeStep, 0.0, 0.0)
    }
}
