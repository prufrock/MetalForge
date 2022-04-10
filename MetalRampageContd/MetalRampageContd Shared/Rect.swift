//
// Created by David Kanenwisher on 12/20/21.
//

import simd
import MetalKit

public struct Rect {
    var min, max: Float2

    public init(min: Float2, max: Float2) {
        self.min = min
        self.max = max
    }

    func renderable() -> ([Float3], [Float2], Float4x4, Color, MTLPrimitiveType) {
        var vertices:[Float3] = []

        vertices.append(Float3(min.x, max.y, 0.0))
        vertices.append(Float3(max.x, max.y, 0.0))
        vertices.append(Float3(max.x, min.y, 0.0))

        vertices.append(Float3(min.x, max.y, 0.0))
        vertices.append(Float3(min.x, min.y, 0.0))
        vertices.append(Float3(max.x, min.y, 0.0))

        return (vertices, [], Float4x4.identity(), .blue, .triangle)
    }

    func renderableObject() -> RNDRObject {
        var vertices:[Float3] = []

        vertices.append(Float3(min.x, max.y, 0.0))
        vertices.append(Float3(max.x, max.y, 0.0))
        vertices.append(Float3(max.x, min.y, 0.0))

        vertices.append(Float3(min.x, max.y, 0.0))
        vertices.append(Float3(min.x, min.y, 0.0))
        vertices.append(Float3(max.x, min.y, 0.0))

        return RNDRObject(vertices: vertices, uv: [], transform: Float4x4.identity(), color: .blue, primitiveType: .triangle, position: Int2())
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
