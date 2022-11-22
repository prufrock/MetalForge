//
//  World.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct World {

    var actors: [Actor]

    init() {
        actors = []
        reset()
    }

    /**
     Set the world back to how it all began...
     */
    private mutating func reset() {
        actors.append(
            Actor(position: MFloat2(space: .world, value: Float2(0.2, 0.4)), model: .square)
        )
    }

    /**
     Update the game.
     - Parameters:
       - timeStep: The amount of time to move it forward.
     */
    mutating func update(timeStep: Float, input: Input) {
        var actor = actors[0]
        actor.position = actor.position + input.movement
        actors[0] = actor
    }
}
