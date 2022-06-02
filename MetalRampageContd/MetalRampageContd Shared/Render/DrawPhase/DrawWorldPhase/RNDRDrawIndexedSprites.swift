//
// Created by David Kanenwisher on 6/1/22.
//

import MetalKit

struct RNDRDrawIndexedSprites: RNDRDrawWorldPhase {

    let renderer: Renderer
    let pipelineCatalog: RNDRPipelineCatalog

    func draw(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        // TODO RNDRObject?
        var renderables: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Texture)] = []
        let model = renderer.model[.unitSquare]!

        renderables += world.sprites.map { billboard in
            (model.vertices, model.uv,
                Float4x4.identity()
                    * Float4x4.translate(x: Float(billboard.position.x), y: Float(billboard.position.y), z: 0.5)
                    * (Float4x4.identity()
                    * Float4x4.rotateX(-(3 * .pi)/2)
                    * Float4x4.rotateY(.pi / 2)
                    // use atan2 to convert the direction vector to an angle
                    // this works because these sprites only rotate about the y axis.
                    * Float4x4.rotateY(atan2(billboard.direction.y, billboard.direction.x))
                    * Float4x4.rotateY(.pi/2)
                )
                , Color.black, MTLPrimitiveType.triangle, billboard.texture)
        }

        // if there's nothing to render bail out
        guard renderables.count > 0 else {
            return
        }

        let indexedObjTransform = renderables.map { _, _, transform, _, _, _ -> Float4x4 in transform }
        let indexedTextureId: [UInt32] = world.sprites.map { (billboard) -> UInt32 in
            switch billboard.texture {
            case .monster:
                return 0
            case .monsterWalk1:
                return 1
            case .monsterWalk2:
                return 2
            case .monsterScratch1:
                return 3
            case .monsterScratch2:
                return 4
            case .monsterScratch3:
                return 5
            case .monsterScratch4:
                return 6
            case .monsterScratch5:
                return 7
            case .monsterScratch6:
                return 8
            case .monsterScratch7:
                return 9
            case .monsterScratch8:
                return 10
            case .monsterHurt:
                return 11
            case .monsterDeath1:
                return 12
            case .monsterDeath2:
                return 13
            case .monsterDead:
                return 14
            case .door1:
                return 15
            case .door2:
                return 16
            case .wall, .crackWall: // .crackWall can share with .wall for now
                return 17
            case .slimeWall:
                return 18
            case .healingPotion:
                return 19
            case .fireBlastPickup:
                return 20
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

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)

        encoder.setFragmentBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(renderer.monster[.monster]!, index: 0)
        encoder.setFragmentTexture(renderer.monster[.monsterWalk1]!, index: 1)
        encoder.setFragmentTexture(renderer.monster[.monsterWalk2]!, index: 2)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch1]!, index: 3)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch2]!, index: 4)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch3]!, index: 5)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch4]!, index: 6)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch5]!, index: 7)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch6]!, index: 8)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch7]!, index: 9)
        encoder.setFragmentTexture(renderer.monster[.monsterScratch8]!, index: 10)
        encoder.setFragmentTexture(renderer.monster[.monsterHurt]!, index: 11)
        encoder.setFragmentTexture(renderer.monster[.monsterDeath1]!, index: 12)
        encoder.setFragmentTexture(renderer.monster[.monsterDeath2]!, index: 13)
        encoder.setFragmentTexture(renderer.monster[.monsterDead]!, index: 14)
        encoder.setFragmentTexture(renderer.door[.door1]!, index: 15)
        encoder.setFragmentTexture(renderer.door[.door2]!, index: 16)
        encoder.setFragmentTexture(renderer.wallTexture!, index: 17)
        encoder.setFragmentTexture(renderer.slimeWallTexture!, index: 18)
        encoder.setFragmentTexture(renderer.healingPotionTexture!, index: 19)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastPickup]!, index: 20)
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
