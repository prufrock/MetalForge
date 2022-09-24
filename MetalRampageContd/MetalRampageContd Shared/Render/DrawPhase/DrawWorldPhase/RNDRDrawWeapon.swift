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

        // There might be a better place for this...
        var fragmentUniforms = FragmentUniforms()
        fragmentUniforms.lightCount = UInt32(world.lighting.lights.count)
        // The camera is at the players position, but it might be worth generalizing this in case I want to move it around.
        fragmentUniforms.cameraPosition = Float3(world.player.position)
        var lights = world.lighting.lights
        lights[0].position = Float3(world.player.position)
        lights[0].coneDirection = Float3(world.player.direction) + Float3(0,0, -0.3)

        let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])
        let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])!
        let normalsBuffer = renderer.device.makeBuffer(bytes: model.normals, length: MemoryLayout<Float3>.stride * model.normals.count, options: [])!

        var wandSpriteSheet = SpriteSheet(textureWidth: 80, textureHeight: 16, spriteWidth: 16, spriteHeight: 16)

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
            textureId = 0
        case .fireBlastFire1:
            textureId = 1
        case .fireBlastFire2:
            textureId = 2
        case .fireBlastFire3:
            textureId = 3
        case .fireBlastFire4:
            textureId = 4
        default:
            textureId = 0
        }

        var shaderCamera = camera
        var transform = Float4x4.translate(x: 0.0, y: 0.0, z: 0.1)
            * Float4x4.scale(x: 2.0, y: 2.0, z: 0.0)

        encoder.setRenderPipelineState(pipelineCatalog.spriteSheetPipeline)
        encoder.setDepthStencilState(renderer.depthStencilState)
        encoder.setCullMode(.back)
        encoder.setVertexBuffer(buffer, offset: 0, index: VertexAttribute.position.rawValue)
        encoder.setVertexBuffer(coordsBuffer, offset: 0, index: VertexAttribute.uvcoord.rawValue)
        encoder.setVertexBuffer(normalsBuffer, offset: 0, index: VertexAttribute.normal.rawValue)
        encoder.setVertexBytes(&shaderCamera, length: MemoryLayout<Float4x4>.stride, index: 3)
        encoder.setVertexBytes(&transform, length: MemoryLayout<Float4x4>.stride, index: 4)
        encoder.setVertexBytes(&textureId, length: MemoryLayout<UInt32>.stride, index: 5)
        encoder.setVertexBytes(&wandSpriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 6)

        let color = GMColor.black
        var fragmentColor = Float4(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)

        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
        encoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 1)
        encoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: BufferIndex.lights.rawValue)
        // select the texture
        switch world.player.animation.texture {
        case .wand, .wandFiring1, .wandFiring2, .wandFiring3, .wandFiring4:
            encoder.setFragmentTexture(renderer.wand[.wandSpriteSheet]!, index: 0)
        case .fireBlastIdle, .fireBlastFire1, .fireBlastFire2, .fireBlastFire3, .fireBlastFire4:
            encoder.setFragmentTexture(renderer.fireBlast[.fireBlastSpriteSheet]!, index: 0)
        default:
            encoder.setFragmentTexture(renderer.wand[.wandSpriteSheet]!, index: 0)
        }

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: model.allVertices().count)
    }
}
