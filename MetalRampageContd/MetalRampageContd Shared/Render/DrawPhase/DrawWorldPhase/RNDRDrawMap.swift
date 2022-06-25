//
// Created by David Kanenwisher on 6/1/22.
//

import Metal

struct RNDRDrawMap: RNDRDrawWorldPhase  {

    private let renderer: RNDRRenderer
    private let pipelineCatalog: RNDRPipelineCatalog

    init(renderer: RNDRRenderer, pipelineCatalog: RNDRPipelineCatalog) {
        self.renderer = renderer
        self.pipelineCatalog = pipelineCatalog
    }

    func draw(world: GMWorld, encoder: MTLRenderCommandEncoder, camera: Float4x4) {
        // TODO replace drawMap with an overheard view of the world
        //Draw map
        var renderables: [RNDRObject] = RNDRTileImage(world: world).tiles
                // filtering white tiles is a goofy shortcut so that only the floor tiles are used for the map
                // eventually this should be replaced with a proper overhead view of the world
                // going to need a way to rip off the ceiling or show only the floor for that
                .filter { $0.0.color == .white && ($0.1 == .crackWall || $0.1 == .wall || $0.1 == .slimeWall || $0.1 == .elevatorSideWall || $0.1 == .elevatorBackWall) }
                .map { $0.0 }
        //Draw player
        renderables.append(world.player.rect.renderableObject())

        //Draw view plane
        let focalLength: Float = 1.0
        let viewWidth: Float = 1.0
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2
        let viewEnd = viewStart + viewPlane
        renderables.append(
            RNDRObject(vertices: [
                viewStart.toFloat3(),
                viewEnd.toFloat3()
            ], uv: [], transform: Float4x4.translate(x: 0.0, y: 0.0, z: 0.0), color: .red, primitiveType: .line, position: Int2())
        )
        // Cast rays
        let columns = 3
        let step = viewPlane / Float(columns)
        var columnPosition = viewStart
        for _ in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = GMRay(origin: world.player.position, direction: rayDirection / viewPlaneDistance)

            var end = world.map.hitTest(ray)
            for sprite in world.sprites {
                guard let hit = sprite.hitTest(ray) else {
                    continue
                }
                let spriteDistance = (hit - ray.origin).length
                if spriteDistance > (end - ray.origin).length {
                    continue
                }
                end = hit
            }

            renderables.append(
                RNDRObject(vertices: [
                    ray.origin.toFloat3(),
                    end.toFloat3()
                ], uv: [], transform: Float4x4.translate(x: 0.0, y: 0.0, z: 0.0), color: .green, primitiveType: .line, position: Int2())
            )
            columnPosition += step
        }

        // Draw sprites
        for line in world.sprites {
            renderables.append(
                RNDRObject(vertices: [
                    line.start.toFloat3(),
                    line.end.toFloat3()
                ], uv: [], transform: Float4x4.translate(x: 0.0, y: 0.0, z: 0.0), color: .green, primitiveType: .line, position: Int2())
            )
        }

        renderables.forEach { rndrObject in
            let buffer = renderer.device.makeBuffer(bytes: rndrObject.vertices, length: MemoryLayout<Float3>.stride * rndrObject.vertices.count, options: [])

            var pixelSize = 1

            var finalTransform =
                camera
                    * Float4x4.scaleY(-1) // flip the map around the y axis
                    * rndrObject.transform

            encoder.setRenderPipelineState(pipelineCatalog.vertexPipeline)
            encoder.setCullMode(.back)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<Float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(rndrObject.color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: rndrObject.primitiveType, vertexStart: 0, vertexCount: rndrObject.vertices.count)
        }
    }
}
