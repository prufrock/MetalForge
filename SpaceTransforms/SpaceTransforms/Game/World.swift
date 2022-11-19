//
//  World.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct World {

    var vertices: [MFloat3]
    var actors: [Actor]

    init() {
        vertices = []
        actors = []
        reset()
    }

    /**
     Set the world back to how it all began...
     */
    private mutating func reset() {
        vertices = [MFloat3(space: .world, value: Float3(0.0, 0.0, 0.0))]
        actors.append(
            Actor(position: MFloat2(space: .world, value: Float2(0.0, 0.0)), model: .dot)
        )
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
