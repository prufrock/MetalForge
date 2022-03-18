//
// Created by David Kanenwisher on 2/19/22.
//

public struct Billboard {
    public var start: Float2
    public var direction: Float2
    public var length: Float
    public var position: Float2
    public var texture: Texture

    public init(start: Float2, direction: Float2, length: Float, position: Float2, texture: Texture) {
        self.start = start
        self.direction = direction
        self.length = length
        self.position = position
        self.texture = texture
    }
}

public extension Billboard {
    var end: Float2 {
        start + direction * length
    }

    func hitTest(_ ray: Ray) -> Float2? {
        var lhs = ray, rhs = Ray(origin: start, direction: direction)

        // calculate slopes and intercepts
        let (slope1, intercept1) = lhs.slopeIntercept
        let (slope2, intercept2) = rhs.slopeIntercept

        // ensure rays are never exactly vertical
        let epsilon: Float = 0.00001
        if abs(lhs.direction.x) < epsilon {
            lhs.direction.x = epsilon
        }

        if slope1 == slope2 {
            return nil
        }

        let x = (intercept1 - intercept2) / (slope2 - slope1)
        let y = slope1 * x + intercept1

        // Check intersection point is in range
        let distanceAlongRay = (x - lhs.origin.x) / lhs.direction.x
        if distanceAlongRay < 0 {
            return nil
        }

        let distanceAlongBillboard = (x - rhs.origin.x) / rhs.direction.x
        if distanceAlongBillboard < 0 || distanceAlongBillboard > length {
            return nil
        }

        return Float2(x, y)
    }
}
