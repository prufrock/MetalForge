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
                shape.vertices.append((Float4(Float(x), Float(y), 0.0, 1.0), .white))
            }
        }
        shape.vertices[0] = (shape.vertices[0].0, .blue)
        shape.vertices[2] = (shape.vertices[2].0, .blue)
        shape.vertices[4] = (shape.vertices[4].0, .blue)
        shape.vertices[6] = (shape.vertices[6].0, .blue)
        return shape
    }
}

struct Vector {
    var x, y: Int
}

struct Shape {
    var vertices: [(Float4, Colors)]
}

