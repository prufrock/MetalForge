//
// Created by David Kanenwisher on 12/16/21.
//

public struct Player {
    public var position: Float2
    public var velocity: Float2
    public let radius: Float = 0.25
    public let speed: Float = 2
    public var direction: Float2
    public var direction3d: Float4x4
    public let turningSpeed: Float = .pi/2

    public init(position: Float2) {
        self.position = position
        self.velocity = Float2(0, 0)
        self.direction = Float2(1, 0)
        self.direction3d = Float4x4(rotateY: .pi/2)
    }
}

public extension Player {
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
}
