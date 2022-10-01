//
// Created by David Kanenwisher on 6/12/22.
//

import Metal

struct RNDRDrawHudElements: RNDRDrawHudPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(hud: GMHud, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = renderer.model[.unitSquare]!

        // TODO: Add Texture to RNDRObject?
        let crossHairs: (RNDRObject, GMTexture, UInt32?) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.scale(x: 0.25, y: 0.25, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0),
            texture: nil
        ), .crosshair, nil)

        let fontSpace: Float = 0.10

        var fontSpriteSheet = SpriteSheet(textureWidth: 148, textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        //TODO pass a sprite index for instance being rendered
        //TODO find a way to pass whether a texture uses a sprite sheet
        var fontSpriteIndex = 0

        var renderables: [(RNDRObject, GMTexture, UInt32?)] = []
        renderables.append(crossHairs)

        let chargesStart: Float2 = Float2(renderer.aspect * 0.9, 0.85)

        let charges = String(Int(max(0, min(99, Int(hud.chargesString) ?? 0)))).leftPadding(toLength: 2, withPad: "0")

        let charges1: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: chargesStart.x - fontSpace * 1, y: chargesStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0),
            texture: nil
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(charges.charInt(at: 0) ?? 0)) ?? 0))

        let charges2: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: chargesStart.x - fontSpace * 0, y: chargesStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0),
            texture: nil
        ), .font, UInt32(hud.font.characters.firstIndex(of: String(charges.charInt(at: 1) ?? 0)) ?? 0))

        let chargesIcon: (RNDRObject, GMTexture, UInt32) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.translate(x: chargesStart.x - fontSpace * 2, y: chargesStart.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
            color: .black,
            primitiveType: .triangle,
            position: Int2(0, 0),
            texture: nil
        ), hud.weaponIcon, 100)

        for i in hud.buttons.indices {
            let button = hud.buttons[i]
            renderables.append((RNDRObject(
                vertices: model.allVertices(),
                uv: model.allUv(),
                transform: Float4x4.translate(x: button.position.x, y: button.position.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
                color: .red,
                primitiveType: .triangle,
                position: Int2(0, 0),
                texture: nil
            ), button.texture, 100))
        }

        for i in hud.touchLocations.indices {
            let touchLocation = hud.touchLocations[i]
            let ndcPosition = touchLocation.toNdcSpace(aspect: renderer.aspect)
            renderables.append((RNDRObject(
                vertices: model.allVertices(),
                uv: model.allUv(),
                transform: Float4x4.translate(x: ndcPosition.x, y: ndcPosition.y, z: 0.0) * Float4x4.scale(x: 0.1, y: 0.1, z: 0.0),
                color: .red,
                primitiveType: .triangle,
                position: Int2(0, 0),
                texture: nil
            ), touchLocation.texture, 100))
        }


        renderables.append(charges1)
        renderables.append(charges2)
        renderables.append(chargesIcon)

        let indexedObjTransform = renderables.map { (object, _, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture, _) -> UInt32 in
            switch texture {
            case .crosshair:
                return 1
            case .healthIcon:
                return 2
            case .font:
                return 3
            case .fireBlastIcon:
                return 4
            case .wandIcon:
                return 5
            case .squareGreen:
                return 6
            case .squarePurple:
                return 7
            default:
                return 0
            }
        }
        let indexedFontSpriteIndex: [UInt32] = renderables.map { (_, _, spriteIndex) -> UInt32 in spriteIndex ?? 100}
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = renderables[0].0.color
        let primitiveType = renderables[0].0.primitiveType

        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let indexBuffer = renderer.device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])

        var pixelSize = 1

        var finalTransform = camera

        encoder.setRenderPipelineState(pipelineCatalog.textureIndexedSpriteSheetPipeline)
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
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastIcon]!, index: 4)
        encoder.setFragmentTexture(renderer.wand[.wandIcon]!, index: 5)
        encoder.setFragmentTexture(renderer.squareGreen, index: 6)
        encoder.setFragmentTexture(renderer.squarePurple, index: 7)

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
