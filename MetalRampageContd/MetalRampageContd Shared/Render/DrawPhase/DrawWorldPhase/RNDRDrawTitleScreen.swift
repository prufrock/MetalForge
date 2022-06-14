//
// Created by David Kanenwisher on 6/13/22.
//

import Metal

class RNDRDrawTitleScreen {

    private let renderer: Renderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: Renderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(game: Game, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = renderer.model[.unitSquare]!

        var fontSpriteSheet = SpriteSheet(textureWidth: 148, textureHeight: 6, spriteWidth: 4, spriteHeight: 6)
        //TODO pass a sprite index for instance being rendered
        //TODO find a way to pass whether a texture uses a sprite sheet
        var fontSpriteIndex = 0

        // TODO: Add Texture to RNDRObject?
        let titleLogo: (RNDRObject, Texture, UInt32?) = (RNDRObject(
            vertices: model.allVertices(),
            uv: model.allUv(),
            transform: Float4x4.scale(x: 0.25, y: 0.25, z: 0.0),
            color: .white,
            primitiveType: .triangle,
            position: Int2(0, 0)
        ), .titleLogo, nil)

        var renderables: [(RNDRObject, Texture, UInt32?)] = []
        renderables.append(titleLogo)

        for index in 0..<game.titleText.count {
            let character = game.titleText.char(at: index)!
            let text: (RNDRObject, Texture, UInt32) = (RNDRObject(
                vertices: model.allVertices(),
                uv: model.allUv(),
                transform: Float4x4.translate(x: (renderer.aspect * 0.0) + (-1 * Float(game.titleText.count - 1) / 2 * 0.01) + (0.01 * Float(index)) , y: -0.1, z: 0.0) * Float4x4.scale(x: 0.008, y: 0.01, z: 0.0),
                color: .yellow,
                primitiveType: .triangle,
                position: Int2(0, 0)
            ), .font, UInt32(game.hud.font.characters.firstIndex(of: String(character)) ?? 0))
            renderables.append(text)
        }

        let indexedObjTransform = renderables.map { (object, _, _) -> Float4x4 in object.transform }
        let indexedTextureId: [UInt32] = renderables.map { (_, texture, _) -> UInt32 in
            switch texture {
            case .font:
                return 3
            case .titleLogo:
                return 1
            default:
                return 0
            }
        }

        let indexedFontSpriteIndex: [UInt32] = renderables.map { (_, _, spriteIndex) -> UInt32 in spriteIndex ?? 100}
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let color = renderables[1].0.color
        let primitiveType = renderables[0].0.primitiveType

        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let indexBuffer = renderer.device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])

        var pixelSize = 1

        var finalTransform = camera * Float4x4.scale(x: 8.5 * renderer.aspect, y: 8.5, z: 0)

        encoder.setRenderPipelineState(pipelineCatalog.textureIndexedSpriteSheetPipeline)
        // TODO why can't I have the depth stencil and the text on the bottom of the screen?
        // encoder.setDepthStencilState(depthStencilState)
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
        encoder.setFragmentTexture(renderer.titleScreen[.titleLogo]!, index: 1)
        encoder.setFragmentTexture(renderer.hud[.font]!, index: 3)

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
