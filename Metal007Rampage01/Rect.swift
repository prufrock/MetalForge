//
// Created by David Kanenwisher on 12/14/21.
//

import Foundation

struct Rect {
    var min, max: Vector

    init(min: Vector, max: Vector) {
        self.min = min
        self.max = max
    }

    func shape() -> Shape {
        var shape = Shape(vertices: [])
        for y in min.y ..< max.y {
            for x in min.x ..< max.x {
                shape.vertices.append(Float4(Float(x), Float(y), 0.0, 1.0))
            }
        }
        return shape
    }
}

struct Vector {
    var x, y: Int
}

struct Shape {
    var vertices: [Float4]
}

