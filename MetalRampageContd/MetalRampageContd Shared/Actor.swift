//
// Created by David Kanenwisher on 3/18/22.
//

import Foundation

protocol Actor {
    var radius: Float {get}
    var position: Float2 {get set}
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

    func intersection(with actor: Actor) -> Float2? {
        rect.intersection(with: actor.rect)
    }
}