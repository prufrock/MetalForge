//
// Created by David Kanenwisher on 3/18/22.
//

import Foundation

protocol GMActor {
    var radius: Float {get}
    var position: Float2 {get set}
    var isDead: Bool { get }
}

extension GMActor {
    var rect: GMRect {
        let halfSize = Float2(radius, radius)
        // the player is centered on the position
        return GMRect(min: position - halfSize, max: position + halfSize)
    }

    func intersection(with map: GMTilemap) -> Float2? {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        var largestIntersection: Float2?
        for y in minY ... maxY {
            for x in minX ... maxX where map[x, y].isWall {
                let wallRect = GMRect(
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
    func intersection(with door: GMDoor) -> Float2? {
        rect.intersection(with: door.rect)
    }

    func intersection(with pushWall: GMPushWall) -> Float2? {
        rect.intersection(with: pushWall.rect)
    }

    /**
     Checks for intersection with the world and doors and push walls and returns a response vector if it does.
     - Parameter world: Door
     - Returns: Float2
     */
    func intersection(with world: GMWorld) -> Float2? {
        if let intersection = intersection(with: world.map) {
            return intersection
        }

        for door in world.doors {
            if let intersection = intersection(with: door) {
                return intersection
            }
        }

        // push walls shouldn't collide with themselves
        for pushWall in world.pushWalls where pushWall.position != position {
            if let intersection = intersection(with: pushWall) {
                return intersection
            }
        }

        return nil
    }

    func intersection(with actor: GMActor) -> Float2? {
        // if either are dead don't consider it an intersection
        // basically this makes it so you can move through dead monsters
        if isDead || actor.isDead {
            return nil
        }

        return rect.intersection(with: actor.rect)
    }

    func isStuck(in world: GMWorld) -> Bool {
        // If outside map
        if position.x < 1 || position.x > world.map.size.x - 1 || position.y < 1 || position.y > world.map.size.y - 1 {
            return true
        }

        // If stuck in a wall
        if world.map[Int(position.x), Int(position.y)].isWall {
            return true
        }

        // If stuck in a push wall
        return world.pushWalls.contains(where: {
            abs(position.x - $0.position.x) < 0.6 && abs(position.y - $0.position.y) < 0.6
        })
    }

    /*
     A collision check where collisions are checked only so many times before simply allowing it so the game doesn't
     lock up.
     */
    mutating func avoidWalls(in world: GMWorld) {
        var attempts = 10
        while attempts > 0, let intersection = intersection(with: world) {
            position -= intersection
            attempts -= 1
        }
    }
}