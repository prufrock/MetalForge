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

            if let clicked = clickLocation {
                list.append(clicked)
            }
            list.append(contentsOf: walls)
            list.append(contentsOf: buttons)

            return list
        }
    }

    var player: Player?

    var walls: [Wall]
    var buttons: [Button]

    var clickLocation: ClickLocation?

    var camera: Camera?
    var overHeadCamera: Camera?
    var floatingCamera: Camera?
    var hudCamera = HudCamera(model: .square)

    init(map:  TileMap) {
        self.map = map
        walls = []
        buttons = []
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
                    walls.append(Wall(position: MFloat2(space: .world, value: position), model: .square))
                }

                let button = map[hud: x, y]
                switch button {
                case .floor:
                    // not going to render walls for now
                    break
                case .wall:
                    buttons.append(Button(position: MFloat2(space: .world, value: position), model: .square))
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
       - input: The actionable changes in the game from the ViewController.
     */
    mutating func update(timeStep: Float, input: Input) {

        var worldPosition: MFloat2? = nil
        if (input.isClicked) {
            let ndcPosition = input.clickCoordinates.toNdcSpace(screenWidth: input.viewWidth, screenHeight: input.viewHeight, flipY: false)
            worldPosition = ndcPosition.toWorldSpace(camera: hudCamera, aspect: input.aspect)
            clickLocation = ClickLocation(model: .square).run { location in
                var newLocation = location
                newLocation.position = worldPosition!
                return newLocation
            }

            // This is *real* ugly but it ensures that an overlapping click only picks a single button by selecting
            // the first one with the largest intersection with the click location.
            if let location = clickLocation {
                var largestIntersection: Float2?
                var largestIntersectedButtonIndex: Int?
                for i in (0 ..< buttons.count) {
                    if let intersection = location.intersection(with: buttons[i]),
                       intersection.length > largestIntersection?.length ?? 0 {
                        var button = buttons[i]
                        button.color = Float3(0.0, 0.5, 1.0)
                        buttons[i] = button
                        largestIntersection = intersection
                        largestIntersectedButtonIndex = i
                    } else {
                        var button = buttons[i]
                        button.color = Float3(0.0, 0.5, 1.0)
                        buttons[i] = button
                    }
                }
                if let chosenIndex = largestIntersectedButtonIndex {
                    var button = buttons[chosenIndex]
                    button.color = Float3(1.0, 0.5, 1.0)
                    buttons[chosenIndex] = button
                }
            }
        }

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
        default:
            break
        }

        player = player?.run {
            var updatedPlayer = $0
            updatedPlayer.position = updatedPlayer.position + (input.movement * vectorTransform)
            // Don't let the player's position get way too big or way too small
            updatedPlayer.position.value.x.formTruncatingRemainder(dividingBy: map.size.x - 1)
            updatedPlayer.position.value.y.formTruncatingRemainder(dividingBy: map.size.y - 1)

            // check if the player intersects with the world
            updatedPlayer.avoidWalls(in: self)
            return updatedPlayer
        }

        if var camera = camera {
            camera.position3d = camera.position3d + (input.cameraMovement * Float3(vectorTransform.x, vectorTransform.y, 1))
            self.camera = camera
        }
    }
}
