//
// Created by David Kanenwisher on 3/15/22.
//

import MetalKit

/**
 A simple struct that has what's needed to render an object.
 */
struct RNDRObject {
    let vertices: [Float3]
    let uv: [Float2]
    let transform: Float4x4
    let color: Color
    let primitiveType: MTLPrimitiveType
}

extension RNDRObject {
    func toTuple() -> ([Float3], [Float2], Float4x4, Color, MTLPrimitiveType) {
        (vertices, uv, transform, color, primitiveType)
    }
}
