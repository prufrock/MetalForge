//
// Created by David Kanenwisher on 12/29/21.
//

public struct Ray {
    public var origin, direction: Float2

    public init(origin: Float2, direction: Float2) {
        self.origin = origin
        self.direction = direction
    }
}

extension Ray {
    var slopeIntercept: (slope: Float, intercept: Float) {
        let slope = direction.y / direction.x
        let intercept = origin.y - slope * origin.x
        return (slope, intercept)
    }
}
