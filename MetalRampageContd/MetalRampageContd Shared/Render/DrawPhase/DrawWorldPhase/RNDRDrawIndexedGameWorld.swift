//
// Created by David Kanenwisher on 5/25/22.
//

import Metal

struct RNDRDrawIndexedGameWorld: RNDRDrawWorldPhase {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(world: World, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        let color = Color.black
        let primitiveType = MTLPrimitiveType.triangle

        if renderer.worldTilesBuffers == nil {
            initializeWorldTilesBuffer(world: world)
        }

        renderer.worldTilesBuffers?.forEach { buffers in
            let buffer = buffers.vertexBuffer
            let indexBuffer = buffers.indexBuffer
            let coordsBuffer = buffers.uvBuffer
            let indexedObjTransform = buffers.indexedTransformations
            let indexedTextureId: [UInt] = buffers.indexedTransformations.map { _ in 0 }

            var pixelSize = 1

            var finalTransform = camera

            var texture: MTLTexture = renderer.colorMapTexture

            switch(buffers.tile) {
            case .wall, .elevatorBackWall, .elevatorSideWall:
                texture = renderer.wallTexture
            case .crackWall:
                texture = renderer.crackedWallTexture
            case .slimeWall:
                texture = renderer.slimeWallTexture
            case .floor, .elevatorFloor:
                texture = renderer.floor
            case .crackFloor:
                texture = renderer.crackedFloor
            case .ceiling:
                texture = renderer.ceiling
            case .doorJamb1:
                texture = renderer.doorJamb[.doorJamb1]!!
            case .doorJamb2:
                texture = renderer.doorJamb[.doorJamb2]!!
            case .wallSwitch:
                // wall switch can animate so check to see if the texture has changed
                //TODO this is a little bit ugly
                buffers.positions.forEach { position in
                    if let s = world.switch(at: Int(position.x), Int(position.y)) {
                        texture = renderer.wallSwitch[s.animation.texture]!!
                    }
                }
            default:
                texture = renderer.colorMapTexture
            }

            var fragmentColor = Float3(color)

            encoder.setRenderPipelineState(pipelineCatalog.textureIndexedPipeline)
            encoder.setDepthStencilState(renderer.depthStencilState)
            encoder.setCullMode(.back)

            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBuffer(coordsBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 2)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 3)
            encoder.setVertexBytes(indexedObjTransform, length: MemoryLayout<Float4x4>.stride * indexedObjTransform.count, index: 4)
            encoder.setVertexBytes(indexedTextureId, length: MemoryLayout<UInt>.stride * indexedTextureId.count, index: 5)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
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

    private func initializeWorldTilesBuffer(world: World) {
        renderer.worldTilesBuffers = Array()
        let index: [UInt16] = [0, 1, 2, 3, 4, 5]

        let model = renderer.model[.unitSquare]! // it better be there!

        Tile.allCases.forEach { tile in
            renderer.worldTiles!.filter {$0.1 == tile}.chunked(into: 64).forEach { chunk in
                let buffer = renderer.device.makeBuffer(bytes: model.allVertices(), length: MemoryLayout<Float3>.stride * model.allVertices().count, options: [])!
                let indexBuffer = renderer.device.makeBuffer(bytes: index, length: MemoryLayout<UInt16>.stride * index.count, options: [])!
                let coordsBuffer = renderer.device.makeBuffer(bytes: model.allUv(), length: MemoryLayout<Float2>.stride * model.allUv().count, options: [])!
                let indexedObjTransform = chunk.map { (rndrObject, _)-> Float4x4 in
                    rndrObject.transform
                }
                renderer.worldTilesBuffers?.append(
                    MetalTileBuffers(
                        vertexBuffer: buffer,
                        indexBuffer: indexBuffer,
                        uvBuffer: coordsBuffer,
                        indexedTransformations: indexedObjTransform,
                        tile: tile,
                        tileCount: chunk.count,
                        index: index,
                        indexCount: index.count,
                        positions:  chunk.map { (rndrObject, _) -> Int2 in rndrObject.position }
                    )
                )
            }
        }
    }
}
