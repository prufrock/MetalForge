//
// Created by David Kanenwisher on 12/29/21.
//

struct GMRay {
     var origin, direction: Float2

    init(origin: Float2, direction: Float2) {
        self.origin = origin
        self.direction = direction
    }
}

extension GMRay {
    var slopeIntercept: (slope: Float, intercept: Float) {
        let slope = direction.y / direction.x
        let intercept = origin.y - slope * origin.x
        return (slope, intercept)
    }
}

/**
 One day figure out how to make this generic.
 */
struct GMRay3d {

    var origin, direction: Float3

    init(origin: Float3, direction: Float3) {
        self.origin = origin
        self.direction = direction
    }

    func pointOnRay(t: Float) -> Float3 {
        origin + t * direction
    }
}
