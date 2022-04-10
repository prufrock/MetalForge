//
// Created by David Kanenwisher on 3/3/22.
//

import MetalKit

struct MetalTileBuffers {
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let uvBuffer: MTLBuffer
    let indexedTransformations: [Float4x4]
    let tile: Tile
    let tileCount: Int
    let index: [UInt16]
    let indexCount: Int
    let positions: [Int2]
}
