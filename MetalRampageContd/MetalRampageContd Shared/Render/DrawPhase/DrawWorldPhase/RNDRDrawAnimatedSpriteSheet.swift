//
// Created by David Kanenwisher on 8/24/22.
//

import Metal

struct RNDRDrawAnimatedSpriteSheet: RNDRDrawWorldPhase {
    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog
    private let textureController: RNDRTextureController

    /**
     Create Draw Phase that can draw animated sprite sheets.
     - Parameters:
       - renderer: the source of rendering information for the draw phase.
       - pipelineCatalog: the pipeline catalog to grab pipeline state objects from.
       - textureController: matches things being rendered with their textures.
     */
    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog, textureController: RNDRTextureController) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
        self.textureController = textureController
    }

    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = renderer.model[.unitSquare]!

        world.sprites.forEach { billboard in
            // TODO Find a way to not have to pass the model twice.
            render(billboard.toRNDRObject(with: model), to: model, from: world, with: camera, using: encoder)
        }
    }

    private func render(_ renderable: RNDRObject, to model: RNDRModel, from world: GMWorld, with camera: Float4x4, using encoder: MTLRenderCommandEncoder) {
        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])!

        let textureComposition = textureController.textureFor(textureType: renderable.textureType!, variant: renderable.textureVariant!)
        var spriteSheet = textureComposition.dimensions
        var textureId: UInt32 = renderable.textureId ?? 0

        var finalTransform = camera * renderable.transform

        let color = GMColor.black
        var fragmentColor = Float4(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)

        encoder.setRenderPipelineState(pipelineCatalog.spriteSheetPipeline)
        encoder.setDepthStencilState(renderer.depthStencilState)
        // need to see the back and the front of a door and other objects that aren't always facing the player.
        encoder.setCullMode(.none)

        encoder.setVertexBuffer(buffer, offset: 0, index: VertexAttribute.position.rawValue)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: VertexAttribute.uvcoord.rawValue)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 3)
        encoder.setVertexBytes(&textureId, length: MemoryLayout<UInt32>.stride, index: 4)
        encoder.setVertexBytes(&spriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 5)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)

        // select the texture
        encoder.setFragmentTexture(renderer.spriteSheets[textureComposition.file]!, index: 0)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: model.allVertices().count)
    }
}
