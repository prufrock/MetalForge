//
//  World.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation
import simd

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

    var camera: Camera?
    var overHeadCamera: Camera?
    var floatingCamera: Camera?

    init(map:  TileMap) {
        self.map = map
        walls = []
        reset()
    }

    /**
     Set the world back to how it all began...
     */
    private mutating func reset() {
        overHeadCamera = CameraOverhead(position: MFloat2(space: .world, value: Float2(0.0, 0.0)), model: .square)
        floatingCamera = CameraFloating(position: MFloat2(space: .world, value: Float2(0.0, 0.0)), model: .square)
        camera = overHeadCamera

        for y in 0..<map.height {
            for x in 0..<map.width {
                let position = Float2(x: Float(x) + 0.5, y: Float(y) + 0.5) // in the center of the tile
                let tile = map[x, y]
                switch tile {
                case .floor:
                    // not going to render walls for now
                    break
                case .wall:
                    walls.append(Wall(position: MFloat2(space: .world, value: position), model: .wfSquare))
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

        //TODO The input vector needs a special world space transform.
        var vectorTransform = Float2(1, -1)
        switch input.camera {
        case .overhead:
            if camera is CameraOverhead {
                overHeadCamera = camera
                break
            }

            camera = overHeadCamera
        case .floatingCamera:
            vectorTransform = Float2(1, 1)
            if camera is CameraFloating {
                floatingCamera = camera
                break
            }
            camera = floatingCamera
        }

        if var player = player {
            player.position = player.position + (input.movement * vectorTransform)
            self.player = player
        }

        if var camera = camera {
            camera.position3d = camera.position3d + (input.cameraMovement * Float3(vectorTransform.x, vectorTransform.y, 1))
            self.camera = camera
        }
    }
}
