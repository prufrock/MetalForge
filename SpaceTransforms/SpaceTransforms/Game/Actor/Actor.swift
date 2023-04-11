//
//  Actor.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/19/22.
//

import Foundation

protocol Actor {
    var position: MF2 {get set}

    // Give the model more meta information.
    // Move modelToUpright and uprightToWorld into model.
    // Allow for dynamic control of the primitive type - switch to wf for debugging
    var model: BasicModels {get}
    var color: Float3 {get set}
    var radius: Float {get}

    var modelToUpright:Float4x4 {get}
    var uprightToWorld:Float4x4 {get}


}

extension Actor {
    var rect: Rect {
        let halfSize = Float2(radius, radius)
        // the rectangle is centered on the position
        return Rect(min: position.value - halfSize, max: position.value + halfSize)
    }

    /**
     Checks for intersection with the world and return a response vector if it does.
     - Parameter world:World
     - Returns: Float2
     */
    func intersection(with world: World) -> Float2? {
        if let intersection = intersection(with: world.map) {
            return intersection
        }

        return nil
    }

    func intersection(with map: TileMap) -> Float2? {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        var largestIntersection: Float2?

        for y in minY ... maxY {
            for x in minX ... maxX where map[x, y].isWall {
                let wallRect = Rect(
                    min: Float2(x: Float(x), y: Float(y)),
                    max: Float2(x: Float(x) + 1, y: Float(y) + 1)
                )
                if let intersection = rect.intersection(with: wallRect),
                   intersection.length > largestIntersection?.length ?? 0 {
                    largestIntersection = intersection
                }
            }
        }

        return largestIntersection
    }

    func intersection(with actor: Actor) -> Float2? {
        rect.intersection(with: actor.rect)
    }
}
