//
// Created by David Kanenwisher on 6/13/22.
//

import Metal

class RNDRDrawEffects: RNDRDrawEffectsPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(effects: [GMEffect], encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        effects.forEach { effect in
            let vertices = [
                Float3(0.0, 0.0, 0.0),
                Float3(1.0, 1.0, 0.0),
                Float3(0.0, 1.0, 0.0),

                Float3(0.0, 0.0, 0.0),
                Float3(1.0, 0.0, 0.0),
                Float3(1.0, 1.0, 0.0),
            ]

            let buffer = renderer.device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = Float4x4.identity()
                * Float4x4.translate(x: 1.0, y: -1.0, z: 0.0)
                * Float4x4.scale(x: 2.0, y: 2.0, z: 0.0)
                * Float4x4.rotateY(-.pi)

            encoder.setCullMode(.back)
            encoder.setRenderPipelineState(pipelineCatalog.effectPipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = effect.asFloat4()
            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float4>.stride, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
    }
}
