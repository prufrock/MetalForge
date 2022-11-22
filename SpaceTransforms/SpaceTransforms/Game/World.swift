//
//  World.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct World {
    private(set) var map: TileMap

    var actors: [Actor] {
        get {
            var list: [Actor] = []
            if let player = player {
                list.append(player)
            }
            list.append(contentsOf: walls)

            return list
        }
    }

    var player: Player?

    var walls: [Wall]

    init(map:  TileMap) {
        self.map = map
        walls = []
        reset()
    }

    /**
     Set the world back to how it all began...
     */
    private mutating func reset() {
        for y in 0..<map.height {
            for x in 0..<map.width {
                let position = Float2(x: Float(x) + 0.5, y: Float(y) + 0.5) // in the center of the tile
                let tile = map[x, y]
                switch tile {
                case .floor:
                    // not going to render walls for now
                    break
                case .wall:
                    walls.append(Wall(position: MFloat2(space: .world, value: position), model: .square))
                }


                let thing = map[thing: x, y]
                switch thing {
                case .nothing:
                    break
                case .player:
                    player = Player(position: MFloat2(space: .world, value: position), model: .square)
                    print(position)
                }

            }
        }
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
