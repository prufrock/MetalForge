//
// Created by David Kanenwisher on 6/1/22.
//

import Metal

struct RNDRDrawIndexedSprites: RNDRDrawWorldPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        // TODO RNDRObject?
        var renderables: [([Float3], [Float2], Float4x4, GMColor, MTLPrimitiveType, GMTexture)] = []
        let model = renderer.model[.unitSquare]!

        renderables += world.sprites.map { billboard in
            (model.vertices, model.uv,
                Float4x4.identity()
                    * Float4x4.translate(x: Float(billboard.position.x), y: Float(billboard.position.y), z: 0.5)
                    * (Float4x4.identity()
                    * Float4x4.rotateX(-(3 * .pi)/2)
                    // use atan2 to convert the direction vector to an angle
                    // this works because these sprites only rotate about the y axis.
                    * Float4x4.rotateY(atan2(billboard.direction.y, billboard.direction.x))
                )
                , GMColor.black, MTLPrimitiveType.triangle, billboard.texture)
        }

        // if there's nothing to render bail out
        guard renderables.count > 0 else {
            return
        }

        let indexedObjTransform = renderables.map { _, _, transform, _, _, _ -> Float4x4 in transform }
        let indexedTextureId: [UInt32] = world.sprites.map { (billboard) -> UInt32 in
            switch billboard.texture {
            case .door1:
                return 0
            case .door2:
                return 1
            case .wall, .crackWall: // .crackWall can share with .wall for now
                return 2
            case .slimeWall:
                return 3
            case .healingPotion:
                return 4
            case .fireBlastPickup:
                return 5
            default:
                return 0
            }
        }

        let vertexBuffer = renderer.device.makeBuffer(bytes: model.vertices, length: MemoryLayout<Float3>.stride * model.vertices.count, options: [])
        let indexBuffer = renderer.device.makeBuffer(bytes: model.index, length: MemoryLayout<UInt16>.stride * model.index.count, options: [])!
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.uv, length: MemoryLayout<Float2>.stride * model.uv.count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        var fragmentColor = Float3(renderables[0].3)

        encoder.setRenderPipelineState(pipelineCatalog.textureIndexedPipeline)
        encoder.setDepthStencilState(renderer.depthStencilState)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexAttribute.position.rawValue)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: VertexAttribute.uvcoord.rawValue)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)

        encoder.setFragmentBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(renderer.wallTexture!, index: 2)
        encoder.setFragmentTexture(renderer.slimeWallTexture!, index: 3)
        encoder.setFragmentTexture(renderer.healingPotionTexture!, index: 4)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastPickup]!, index: 5)
        encoder.drawIndexedPrimitives(
            type: renderables[0].4,
            indexCount: model.index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }

}
