//
// Created by David Kanenwisher on 12/13/21.
//

import Foundation
import MetalKit

public class Renderer: NSObject {
    let view: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    public var aspect: Float = 1.0

    public init(_ view: MTKView, width: Int, height: Int) {
        self.view = view

        guard let newDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        view.device = newDevice
        view.clearColor = MTLClearColor(.black)

        device = newDevice

        guard let newCommandQueue = device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        commandQueue = newCommandQueue

        guard let library = device.makeDefaultLibrary() else {
            fatalError("""
                       What in the what?! The library couldn't be loaded.
                       """)
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let defaultPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        pipeline = defaultPipelineState

        super.init()
    }

    public func render(_ world: World) {

        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
            fatalError("""
                       Ugh, no command buffer. What the heck!
                       """)
        }

        guard let descriptor = view.currentRenderPassDescriptor, let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("""
                       Dang it, couldn't create a command encoder.
                       """)


        }

        let worldTransform = Float4x4.identity()
            * Float4x4(scaleY: -1)

        let cameraTransform = Float4x4.identity()
            * Float4x4(translateX: -0.7, y: 0.9, z: 0)
            * Float4x4(scaleX: 0.03, y: 0.03, z: 1.0)
            * Float4x4(scaleY: aspect)

        //Draw map
        //TODO make this a type
        var renderables: [([Float3], Float4x4, Color, MTLPrimitiveType)] = TileImage(map: world.map).tiles
        //Draw player
        renderables.append(world.player.rect.renderable())
        //Draw line of sight line
        let ray = Ray(origin: world.player.position, direction: world.player.direction)
        let end = world.map.hitTest(ray)
        renderables.append(
            ([
                world.player.position.toFloat3(),
                end.toFloat3()
            ], Float4x4.identity(), .green, .line)
        )
        //Draw view plane
        let focalLength: Float = 1.0
        let viewWidth: Float = 1.0
        let viewPlane = world.player.direction.orthogonal * viewWidth
        let viewCenter = world.player.position + world.player.direction * focalLength
        let viewStart = viewCenter - viewPlane / 2
        let viewEnd = viewStart + viewPlane
        renderables.append(
            ([
                viewStart.toFloat3(),
                viewEnd.toFloat3()
            ], Float4x4.init(translateX: 0.0, y: 0.0, z: 0.0), .red, .line)
        )
        // Cast rays
        let columns = 300
        let step = viewPlane / Float(columns)
        var columnPosition = viewStart
        for _ in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(origin: world.player.position, direction: rayDirection / viewPlaneDistance)
            let end = world.map.hitTest(ray)
            renderables.append(
                ([
                    ray.origin.toFloat3(),
                    end.toFloat3()
                ], Float4x4.init(translateX: 0.0, y: 0.0, z: 0.0), .green, .line)
            )
            columnPosition += step
        }
        // Draw wall
//        step = viewPlane / Float(columns)
        columnPosition = viewStart
        let bitmapHeight = 1
        for x in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length
            let ray = Ray(
                origin: world.player.position,
                direction: rayDirection / viewPlaneDistance
            )
            let end = world.map.hitTest(ray)
            let wallDistance = (end - ray.origin).length

            // Draw wall
            let wallHeight:Float = 5.0
            let height = wallHeight * focalLength / wallDistance * Float(1.0)
            let wallColor: Color
            if end.x.rounded(.down) == end.x {
                wallColor = .white
            } else {
                wallColor = .grey
            }

            let drawWalls = false
            if (drawWalls) {
                renderables.append(
                    ([
                        Float3(x: Float(x), y: Float(bitmapHeight) - height, z: 0.0),
                        Float3(x: Float(x), y: Float(bitmapHeight) + height, z: 0.0),
                    ], Float4x4.identity()
                        * Float4x4.init(translateX: -7.0, y: 2.0, z: 0.0)
                        * Float4x4.init(scaleX: 0.1, y: 1.0, z: 1.0), wallColor, .line)
                )
            }
            columnPosition += step
        }

        renderables.forEach { (vertices, objTransform, color, primitiveType) in
            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = cameraTransform * worldTransform * objTransform

            encoder.setRenderPipelineState(pipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertices.count)
        }

        cameraRendering(world: world, encoder: encoder)

        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func cameraRendering(world: World, encoder: MTLRenderCommandEncoder) {
        var renderables: [([Float3], Float4x4, Color, MTLPrimitiveType)] = []

        renderables += LineCube(Float4x4(scaleX: 0.1, y: 0.1, z: 0.1))
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4(translateX: 1.0, y: 0.0, z: 0.0)
                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
        )
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4(translateX: -1.0, y: 0.0, z: 0.0)
                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
        )
        renderables += LineCube(
            Float4x4.identity()
                * Float4x4(translateX: 0.0, y: 1.0, z: 0.0)
                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4(translateX: 0.0, y: -1.0, z: 0.0)
                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4(translateX: 0.0, y: 0.0, z: 1.0)
                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
        )

        renderables += LineCube(
            Float4x4.identity()
                * Float4x4(translateX: 0.0, y: 0.0, z: -1.0)
                * Float4x4(scaleX: 0.1, y: 0.1, z: 0.1)
        )


        renderables += (TileImage(map: world.map).tiles)

        let cameraTransform = Float4x4.identity()
            * Float4x4.perspectiveProjection(fov: .pi / 3, nearPlane: 0.1, farPlane: 1.0)
            * Float4x4(scaleY: aspect)
            * (
            Float4x4.identity()
            * Float4x4(translateX: 0.0, y: 0.0, z: 0.1)
            * world.player.position.toTranslation()
            * Float4x4(rotateX: -(3 * .pi)/2)
            * (world.player.direction3d * Float4x4(scaleX: 1.0, y: 1.0, z: 1.0))
        ).inverse

        let worldTransform = Float4x4.identity()

        renderables.forEach { (vertices, objTransform, color, primitiveType) in
            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float3>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = cameraTransform * worldTransform * objTransform

            encoder.setRenderPipelineState(pipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float3(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float3>.stride, index: 0)
            encoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vertices.count)
        }
    }
}

// Sitting with its bottom center on the origin
func LineCube(_ transformation: Float4x4 = Float4x4.identity()) -> [([Float3], Float4x4, Color, MTLPrimitiveType)] {
    return [
        (
            // xy z-0.5
            [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 1.0, -0.5),

                Float3(-0.5, 1.0, -0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ],
            transformation,
            .green,
            .line
        ),
        (
            // xy z1
            [
                Float3(-0.5, 0.0, 0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(-0.5, 0.0, 0.5),
            ],
            transformation,
            .red,
            .line
        ),
        (
             //xz y0
            [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, 0.5),

                Float3(-0.5, 0.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ],
            transformation,
            .blue,
            .line
        ),
        (
            //xz y1
            [
                Float3(-0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, -0.5),
            ],
            transformation,
            .white,
            .line
        )
    ]
}