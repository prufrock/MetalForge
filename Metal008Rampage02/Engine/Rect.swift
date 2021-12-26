//
// Created by David Kanenwisher on 12/20/21.
//

import simd

public struct Rect {
    var min, max: Float2

    public init(min: Float2, max: Float2) {
        self.min = min
        self.max = max
    }

    func renderable() -> ([Float4], Float4x4, Color) {
        var vertices:[Float4] = []

        vertices.append(Float4(min.x, max.y, 0.0, 1.0))
        vertices.append(Float4(max.x, max.y, 0.0, 1.0))
        vertices.append(Float4(max.x, min.y, 0.0, 1.0))

        vertices.append(Float4(min.x, max.y, 0.0, 1.0))
        vertices.append(Float4(min.x, min.y, 0.0, 1.0))
        vertices.append(Float4(max.x, min.y, 0.0, 1.0))

        return (vertices, Float4x4.init(scaleX: 1, y: -1, z: 1), .blue)
    }
}
