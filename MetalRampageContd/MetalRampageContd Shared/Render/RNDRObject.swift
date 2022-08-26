//
// Created by David Kanenwisher on 3/15/22.
//

import Metal

/**
 A simple struct that has what's needed to render an object.
 */
struct RNDRObject {
    let vertices: [Float3]
    let uv: [Float2]
    let transform: Float4x4
    let color: GMColor
    let primitiveType: MTLPrimitiveType
    let position: Int2 // I seem to have forgotten what this is for
    let texture: GMTexture? // not everything has a texture
}

extension RNDRObject {
    func toTuple() -> ([Float3], [Float2], Float4x4, GMColor, MTLPrimitiveType, GMTexture?) {
        (vertices, uv, transform, color, primitiveType, texture)
    }
}
