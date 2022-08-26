//
// Created by David Kanenwisher on 8/24/22.
//

import Metal

struct RNDRDrawAnimatedSpriteSheet: RNDRDrawWorldPhase {
    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = renderer.model[.unitSquare]!

        let renderables = world.monsterSprites.map { billboard in
            RNDRObject(
                vertices: model.vertices,
                uv: model.uv,
                transform: Float4x4.identity()
                    * Float4x4.translate(x: Float(billboard.position.x), y: Float(billboard.position.y), z: 0.5)
                    * (Float4x4.identity()
                    * Float4x4.rotateX(-(3 * .pi)/2)
                    // use atan2 to convert the direction vector to an angle
                    // this works because these sprites only rotate about the y axis.
                    * Float4x4.rotateY(atan2(billboard.direction.y, billboard.direction.x))),
                color: GMColor.black,
                primitiveType: MTLPrimitiveType.triangle,
                position: Int2(),
                texture: billboard.texture
            )
        }

        renderables.forEach { render($0, to: model, from: world, with: camera, using: encoder) }
    }

    private func render(_ renderable: RNDRObject, to model: RNDRModel, from world: GMWorld, with camera: Float4x4, using encoder: MTLRenderCommandEncoder) {
        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])!

        // TODO: determine sprite sheet dimensions for renderable
        var spriteSheet = SpriteSheet(textureWidth: 128, textureHeight: 32, spriteWidth: 16, spriteHeight: 16)

        // TODO: determine textureId for renderable
        // select the texture
        var textureId: UInt32
        switch renderable.texture {
        case .monster:
            textureId = 0
        case .monsterWalk1:
            textureId = 1
        case .monsterWalk2:
            textureId = 2
        case .monsterScratch1:
            textureId = 3
        case .monsterScratch2:
            textureId = 4
        case .monsterScratch3:
            textureId = 5
        case .monsterScratch4:
            textureId = 6
        case .monsterScratch5:
            textureId = 7
        case .monsterScratch6:
            textureId = 8
        case .monsterScratch7:
            textureId = 9
        case .monsterScratch8:
            textureId = 10
        case .monsterHurt:
            textureId = 11
        case .monsterDeath1:
            textureId = 12
        case .monsterDeath2:
            textureId = 13
        case .monsterDead:
            textureId = 14
        default:
            textureId = 0
        }

        var pixelSize = 1

        var finalTransform = camera * renderable.transform

        encoder.setRenderPipelineState(pipelineCatalog.spriteSheetPipeline)
        encoder.setDepthStencilState(renderer.depthStencilState)
        encoder.setCullMode(.back)
        encoder.setVertexBuffer(buffer, offset: 0, index: VertexAttribute.position.rawValue)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: VertexAttribute.uvcoord.rawValue)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 3)
        encoder.setVertexBytes(&textureId, length: MemoryLayout<UInt32>.stride, index: 4)
        encoder.setVertexBytes(&spriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 5)

        let color = GMColor.black
        var fragmentColor = Float4(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        // select the texture
        encoder.setFragmentTexture(renderer.monster[.monsterSpriteSheet]!, index: 0)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: model.allVertices().count)
    }
}
