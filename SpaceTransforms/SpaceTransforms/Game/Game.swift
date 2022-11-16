//
//  Game.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct Game {
    private(set) var world: World

    init() {
        // Game manages the world
        // Seems like we should start at level 0
        self.world = World()
    }

    /**
     Update the game.
     - Parameters:
       - timeStep: The amount of time to move it forward.
     */
    mutating func update(timeStep: Float) {

    }
}
