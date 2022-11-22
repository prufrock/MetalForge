//
//  World.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct World {

    var actors: [Actor] {
        get {
            var list: [Actor] = []
            if let player = player {
                list.append(player)
            }

            return list
        }
    }

    var player: Actor?

    init() {
        player = Actor(position: MFloat2(space: .world, value: Float2(0.2, 0.4)), model: .square)
        reset()
    }

    /**
     Set the world back to how it all began...
     */
    private mutating func reset() {
        player = Actor(position: MFloat2(space: .world, value: Float2(0.2, 0.4)), model: .square)
    }

    /**
     Update the game.
     - Parameters:
       - timeStep: The amount of time to move it forward.
     */
    mutating func update(timeStep: Float, input: Input) {
        
        if var player = player {
            player.position = player.position + input.movement
            self.player = player
        }
    }
}
