//
//  DrawWeapon.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 5/24/22.
//

import Metal

struct RNDRDrawWeapon: RNDRDrawWorldPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let model = renderer.model[.unitSquare]!

        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])!

        // TODO convert to sprite sheets
        // select the texture
        var textureId: UInt32
        switch world.player.animation.texture {
        case .wand:
            textureId = 0
        case .wandFiring1:
            textureId = 1
        case .wandFiring2:
            textureId = 2
        case .wandFiring3:
            textureId = 3
        case .wandFiring4:
            textureId = 4
        case .fireBlastIdle:
            textureId = 5
        case .fireBlastFire1:
            textureId = 6
        case .fireBlastFire2:
            textureId = 7
        case .fireBlastFire3:
            textureId = 8
        case .fireBlastFire4:
            textureId = 9
        default:
            textureId = 0
        }

        var pixelSize = 1

        var finalTransform = camera
            * Float4x4.translate(x: 0.0, y: 0.0, z: 0.1)
            * Float4x4.scale(x: 2.0, y: 2.0, z: 0.0)

        encoder.setRenderPipelineState(pipelineCatalog.texturePipeline)
        encoder.setDepthStencilState(renderer.depthStencilState)
        encoder.setCullMode(.back)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 3)
        encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 4)
        encoder.setVertexBytes(&textureId, length: MemoryLayout<Float>.stride, index: 5)

        let color = GMColor.black
        var fragmentColor = Float4(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentTexture(renderer.wand[.wand]!, index: 0)
        encoder.setFragmentTexture(renderer.wand[.wandFiring1]!, index: 1)
        encoder.setFragmentTexture(renderer.wand[.wandFiring2]!, index: 2)
        encoder.setFragmentTexture(renderer.wand[.wandFiring3]!, index: 3)
        encoder.setFragmentTexture(renderer.wand[.wandFiring4]!, index: 4)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastIdle]!, index: 5)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastFire1]!, index: 6)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastFire2]!, index: 7)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastFire3]!, index: 8)
        encoder.setFragmentTexture(renderer.fireBlast[.fireBlastFire4]!, index: 9)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: model.allVertices().count)
    }
}
