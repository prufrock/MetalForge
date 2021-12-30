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
            * Float4x4(translateX: -0.32, y: 0.65, z: 0)
            * Float4x4(scaleX: 0.09, y: 0.09, z: 1.0)
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

        encoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            fatalError("""
                       Wakoom! Attempted to get the view's drawable and everything fell apart! Boo!
                       """)
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
