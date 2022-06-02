//
// Created by David Kanenwisher on 6/1/22.
//

import MetalKit

struct RNDRDrawReferenceMarkers: RNDRDrawWorldPhase  {

    let renderer: Renderer
    let pipelineCatalog: RNDRPipelineCatalog

    func draw(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        var renderables: [RNDRObject] = []

        renderables += LineCube(Float4x4.scale(x: 0.1, y: 0.1, z: 0.1))
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 1.0, y: 0.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: -1.0, y: 0.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 1.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: -1.0, z: 0.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 0.0, z: 1.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4.translate(x: 0.0, y: 0.0, z: -1.0)
                    .scaledBy(x: 0.1, y: 0.1, z: 0.1)
        )

        let worldTransform = Float4x4.identity()

        renderables.forEach { rndrObject in
            let buffer = renderer.device.makeBuffer(bytes: rndrObject.vertices, length: MemoryLayout<Float3>.stride * rndrObject.vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = camera * worldTransform * rndrObject.transform

            encoder.setRenderPipelineState(pipelineCatalog.vertexPipeline)
            encoder.setDepthStencilState(renderer.depthStencilState)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(rndrObject.color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: rndrObject.primitiveType, vertexStart: 0, vertexCount: rndrObject.vertices.count)
        }
    }
}
