//
// Created by David Kanenwisher on 6/10/22.
//

import Metal

struct RNDRDrawHealth: RNDRDrawHudPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(hud: GMHud, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = renderer.model[.unitSquare]!

        let heartSpace: Float = 0.11
        // the hudCamera adjusts x by the aspect ratio so the x needs to be adjusted by the aspect here as well.
        let heartStart: Float2 = Float2(renderer.aspect * -0.9, 0.85)

        let playerHealth = String(hud.healthString).leftPadding(toLength: 3, withPad: "0")

        let healthTint: GMColor = hud.healthTint

        let heart1: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 0, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .black,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .healthIcon, 100)

        let health1: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 1, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: healthTint,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(playerHealth.charInt(at: 0) ?? 0)) ?? 0))

        let health2: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 2, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: healthTint,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(playerHealth.charInt(at: 1) ?? 0)) ?? 0))

        let health3: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: heartStart.x + heartSpace * 3, y: heartStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: healthTint,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(playerHealth.charInt(at: 2) ?? 0)) ?? 0))

        var fontSpriteSheet = SpriteSheet(textureWidth: Float(hud.font.characters.count * 4), textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        var fontSpriteIndex = 0 // TODO let the shader select the sprite sheet

        var renderables: [(RNDRObject, GMTexture, UInt32?)] = []

        renderables.append(heart1)
        renderables.append(health1)
        renderables.append(health2)
        renderables.append(health3)

        let indexedObjTransform = renderables.map { (object, _, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture, _) -> UInt32 in
            switch texture {
            case .crosshair:
                return 1
            case .healthIcon:
                return 2
            case .font:
                return 3
            case .fireBlastPickup:
                return 4
            case .wand:
                return 5
            default:
                return 0
            }
        }
        let indexedFontSpriteIndex: [UInt32] = renderables.map { (_, _, spriteIndex) -> UInt32 in spriteIndex ?? 100}
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = healthTint
        let primitiveType = renderables[0].0.primitiveType

        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let indexBuffer = renderer.device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        encoder.setRenderPipelineState(pipelineCatalog.textureIndexedSpriteSheetPipeline)
        encoder.setDepthStencilState(renderer.depthStencilState)
        // Setting this to none for now until I can figure out how to make doors draw on both sides.
        encoder.setCullMode(.none)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
        encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)
        encoder.setVertexBytes(&fontSpriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 6)
        encoder.setVertexBytes(&fontSpriteIndex, length: MemoryLayout<UInt32>.stride, index: 7)
        encoder.setVertexBytes(indexedFontSpriteIndex, length: MemoryLayout<UInt32>.stride * indexedFontSpriteIndex.count, index: 8)

        var fragmentColor = Float3(color)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(renderer.colorMapTexture!, index: 0)
        encoder.setFragmentTexture(renderer.hud[.crosshair]!, index: 1)
        encoder.setFragmentTexture(renderer.hud[.healthIcon]!, index: 2)
        encoder.setFragmentTexture(renderer.hud[.font]!, index: 3)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastPickup]!, index: 4)
        encoder.setFragmentTexture(renderer.wand[.wand]!, index: 5)

        encoder.drawIndexedPrimitives(
            type: primitiveType,
            indexCount: index.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            instanceCount: renderables.count
        )
    }
}
