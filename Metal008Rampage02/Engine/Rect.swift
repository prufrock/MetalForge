//
// Created by David Kanenwisher on 12/20/21.
//

import simd

public struct Rect {
    var min, max: Float2
    private let adj: Float = -0.5

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

        //TODO re-work rendering to not need this -0.5 adjustment
        vertices = vertices.map{ Float4x4.init(translateX: adj, y: adj, z: 0.0) * $0 }

        return (vertices, Float4x4.init(scaleX: 1, y: -1, z: 1), .blue)
    }
}

public extension Rect {
    func intersection(with rect: Rect) -> Float2? {
        let left = Float2(x: max.x - rect.min.x, y: 0)
        if left.x <= 0 {
            return nil
        }
        let right = Float2(x: min.x - rect.max.x, y: 0)
        if right.x >= 0 {
            return nil
        }
        let up = Float2(x: 0, y: max.y - rect.min.y)
        if up.y <= 0 {
            return nil
        }
        let down = Float2(x: 0, y: min.y - rect.max.y)
        if down.y >= 0 {
            return nil
        }
        return [left, right, up, down].sorted(by: { $0.length < $1.length}).first
    }
}
