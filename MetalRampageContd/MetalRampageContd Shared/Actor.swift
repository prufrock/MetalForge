//
// Created by David Kanenwisher on 3/18/22.
//

import Foundation

protocol Actor {
    var radius: Float {get}
    var position: Float2 {get set}
    var isDead: Bool { get }
}

extension Actor {
    var rect: Rect {
        let halfSize = Float2(radius, radius)
        // the player is centered on the position
        return Rect(min: position - halfSize, max: position + halfSize)
    }

    func intersection(with map: Tilemap) -> Float2? {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        var largestIntersection: Float2?
        for y in minY ... maxY {
            for x in minX ... maxX where map[x, y].isWall {
                let wallRect = Rect(
                    min: Float2(x: Float(x), y: Float(y)),
                    max: Float2(x: Float(x + 1), y: Float(y + 1))
                )
                if let intersection = rect.intersection(with: wallRect),
                   intersection.length > largestIntersection?.length ?? 0 {
                    largestIntersection = intersection
                }
            }
        }
        return largestIntersection
    }

    /**
     If this rectangle intersection with the door return the response vector
     - Parameter door: Door
     - Returns: Float2
     */
    func intersection(with door: Door) -> Float2? {
        rect.intersection(with: door.rect)
    }

    func intersection(with pushWall: PushWall) -> Float2? {
        rect.intersection(with: pushWall.rect)
    }

    /**
     Checks for intersection with the world and doors and push walls and returns a response vector if it does.
     - Parameter world: Door
     - Returns: Float2
     */
    func intersection(with world: World) -> Float2? {
        if let intersection = intersection(with: world.map) {
            return intersection
        }

        for door in world.doors {
            if let intersection = intersection(with: door) {
                return intersection
            }
        }

        for pushWall in world.pushWalls {
            if let intersection = intersection(with: pushWall) {
                return intersection
            }
        }

        return nil
    }

    func intersection(with actor: Actor) -> Float2? {
        // if either are dead don't consider it an intersection
        // basically this makes it so you can move through dead monsters
        if isDead || actor.isDead {
            return nil
        }

        return rect.intersection(with: actor.rect)
    }

    /*
     A collision check where collisions are checked only so many times before simply allowing it so the game doesn't
     lock up.
     */
    mutating func avoidWalls(in world: World) {
        var attempts = 10
        while attempts > 0, let intersection = intersection(with: world) {
            position -= intersection
            attempts -= 1
        }
    }
}