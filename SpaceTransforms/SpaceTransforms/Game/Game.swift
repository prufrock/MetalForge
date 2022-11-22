//
//  Game.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct Game {
    private(set) var world: World
    private let levels: [TileMap]


    init(levels: [TileMap]) {
        self.levels = levels
        // Game manages the world
        // Seems like we should start at level 0
        world = World(map: levels[0])
    }

    /**
     Update the game.
     - Parameters:
       - timeStep: The amount of time to move it forward.
     */
    mutating func update(timeStep: Float, input: Input) {
        world.update(timeStep: timeStep, input: input)
    }
}
