//
// Created by David Kanenwisher on 5/25/22.
//

import Metal

/**
 Draws the walls and floors and ceilings of the game world.
 */
struct RNDRDrawIndexedGameWorldLighting: RNDRDrawWorldPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog
    private let textureController: RNDRTextureController

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog, textureController: RNDRTextureController) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
        self.textureController = textureController
    }

    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let color = GMColor.black
        let primitiveType = MTLPrimitiveType.triangle

        if renderer.worldTilesBuffers == nil {
            initializeWorldTilesBuffer(world: world)
        }

        guard let worldTilesBuffers = renderer.worldTilesBuffers else{ return }

        // I had to change from forEach to for in after updating xcode. Don't quite understand why.
        for buffers in worldTilesBuffers {
            // There might be a better place for this...
            var fragmentUniforms = FragmentUniforms()
            fragmentUniforms.lightCount = UInt32(world.lighting.lights.count)
            // The camera is at the players position, but it might be worth generalizing this in case I want to move it around.
            fragmentUniforms.cameraPosition = Float3(world.player.position)
            var lights = world.lighting.lights

            let buffer = buffers.vertexBuffer
            let indexBuffer = buffers.indexBuffer
            let coordsBuffer = buffers.uvBuffer
            let indexedModelTransform = buffers.indexedTransformations
            let normalsBuffer = renderer.device.makeBuffer(bytes: buffers.normals, length: MemoryLayout<Float3>.stride * buffers.normals.count, options: [])!
            // With the way I am rendering only 1 type of tile at a time it's a little silly to pass duplicate
            // texture ids. I am going to keep for now though because:
            // 1. It sets things up to later support rendering a smaller set of tiles all with different textures.
            // 2. It makes the path a little clearer for how to get to animated wall textures.
            // 3. It's a good example of how to use indexed rendering with sprite sheets.
            let indexedTextureId: [UInt32] = buffers.indexedTransformations.map { _ in
                switch(buffers.tile) {
                case .wall, .elevatorBackWall, .elevatorSideWall:
                    return 0
                case .crackWall:
                    return 1
                case .slimeWall:
                    return 2
                case .floor, .elevatorFloor:
                    return 3
                case .crackFloor:
                    return 4
                case .ceiling:
                    return 5
                case .doorJamb1:
                    return 6
                case .doorJamb2:
                    return 7
                case .wallSwitch:
                    // wall switch can animate so check to see if the texture has changed
                    //TODO this is a little bit ugly
                    var switchTextureId: UInt32 = 0
                    buffers.positions.forEach { position in
                        if let s = world.switch(at: Int(position.x), Int(position.y)) {
                            switch(s.animation.texture) {
                            case .switch1:
                                switchTextureId = 8
                            case .switch2:
                                switchTextureId = 9
                            case .switch3:
                                switchTextureId = 10
                            case .switch4:
                                switchTextureId = 11
                            default:
                                switchTextureId = 8
                            }
                        }
                    }
                    return switchTextureId
                default:
                    return 0
                }
            }

            var camera = camera

            let textureComposition = textureController.textureFor(textureType: .wall, variant: .none)
            let texture = renderer.spriteSheets[textureComposition.file] ?? renderer.colorMapTexture
            var spriteSheet = textureComposition.dimensions

            var fragmentColor = Float3(color)

            encoder.setRenderPipelineState(pipelineCatalog.textureIndexedSpriteSheetLightingPipeline)
            encoder.setDepthStencilState(renderer.depthStencilState)
            encoder.setCullMode(.back)

            encoder.setVertexBuffer(buffer, offset: 0, index: VertexAttribute.position.rawValue)
            encoder.setVertexBuffer(coordsBuffer, offset: 0, index: VertexAttribute.uvcoord.rawValue)
            encoder.setVertexBuffer(normalsBuffer, offset: 0, index: VertexAttribute.normal.rawValue)
            encoder.setVertexBytes(&camera, length: MemoryLayout<Float4x4>.stride, index: 3)
            encoder.setVertexBytes(indexedModelTransform, length: MemoryLayout<Float4x4>.stride * indexedModelTransform.count, index: 4)
            encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt32>.stride * indexedTextureId.count, index: 5)
            encoder.setVertexBytes(&spriteSheet, length: MemoryLayout<SpriteSheet>.stride, index: 6)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 1)
            encoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: BufferIndex.lights.rawValue)
            encoder.setFragmentTexture(texture, index: 0)
            encoder.drawIndexedPrimitives(
                type: primitiveType,
                indexCount: buffers.indexCount,
                indexType: .uint16,
                indexBuffer: indexBuffer,
                indexBufferOffset: 0,
                instanceCount: buffers.tileCount
            )
        }
    }

    private func initializeWorldTilesBuffer(world: GMWorld) {
        renderer.worldTilesBuffers = Array()
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let model = renderer.model[.unitSquare]! // it better be there!

        GMTile.allCases.forEach { tile in
            renderer.worldTiles!.filter {$0.1 == tile}.chunked(into: 64).forEach { chunk in
                // TODO should model.allVertices be model.vertices?
                let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])!
                let indexBuffer = renderer.device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
                let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])!
                let indexedObjTransform = chunk.map { (rndrObject, _)-> Float4x4 in
                    rndrObject.transform
                }
                renderer.worldTilesBuffers?.append(
                    RNDRMetalTileBuffers(
                        vertexBuffer: buffer,
                        indexBuffer: indexBuffer,
                        uvBuffer: coordsBuffer,
                        indexedTransformations: indexedObjTransform,
                        tile: tile,
                        tileCount: chunk.count,
                        index: index,
                        indexCount: index.count,
                        positions:  chunk.map { (rndrObject, _) -> Int2 in rndrObject.position },
                        normals: model.normals
                    )
                )
            }
        }
    }
}
