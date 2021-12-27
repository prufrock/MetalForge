//
// Created by David Kanenwisher on 12/16/21.
//

public struct Player {
    public var position: Float2
    public var velocity: Float2
    public let radius: Float = 0.25
    public let speed: Float = 2

    public init(position: Float2) {
        self.position = position
        self.velocity = Float2([0, 0])
    }
}

public extension Player {
    var rect: Rect {
        let halfSize = Float2(radius, radius)
        // the player is centered on the position
        return Rect(min: position - halfSize, max: position + halfSize)
    }

    func isIntersecting(map: Tilemap) -> Bool {
        let minX = Int(rect.min.x), maxX = Int(rect.max.x)
        let minY = Int(rect.min.y), maxY = Int(rect.max.y)
        for y in minY ... maxY {
            for x in minX ... maxX {
                if map[x, y].isWall {
                    return true
                }
            }
        }
        return false
    }
}