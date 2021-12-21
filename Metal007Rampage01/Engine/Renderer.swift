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
    var aspect: Float = 1.0
    // Need to have the originalBitmap so we don't have to keep turning off "pixels" as it's animated
    public private(set) var originalBitmap: Bitmap
    public private(set) var bitmap: Bitmap
    private var scale: Float
    private var world = World()
    private var lastFrameTime = CACurrentMediaTime()

    public init(_ view: MTKView, width: Int, height: Int) {
        self.view = view
        originalBitmap = Bitmap(width: width, height: height, color: .white)
        bitmap = self.originalBitmap
        scale = Float(bitmap.height) / world.size.y

        guard let newDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("""
                       I looked in the computer and didn't find a device...sorry =/
                       """)
        }

        view.device = newDevice

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

        view.delegate = self
        view.clearColor = MTLClearColor(.black)
    }

    private func render(_ world: World) {
        bitmap = originalBitmap

        //Draw player
        var rect = world.player.rect
        rect.min *= scale
        rect.max *= scale
        bitmap.fill(rect: rect, color: .blue)

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

        let transform = Float4x4.identity()
            * Float4x4(translateX: -0.32, y: 0.65, z: 0)
            * Float4x4(scaleX: 0.09, y: 0.09, z: 1.0)
            * Float4x4(scaleY: aspect)


        let tile = [
            Float4(-0.5, 0.5, 0.0, 1.0),
            Float4(0.5, 0.5, 0.0, 1.0),
            Float4(0.5, -0.5, 0.0, 1.0),

            Float4(0.5, -0.5, 0.0, 1.0),
            Float4(-0.5, -0.5, 0.0, 1.0),
            Float4(-0.5, 0.5, 0.0, 1.0),
        ]

        let tiles: [([Float4], Float4x4, Color)] = TileImage(bitmap: bitmap).tiles

        tiles.forEach { (vertices, objTransform, color) in
            let buffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Float4>.stride * vertices.count, options: [])

            var pixelSize = 1

            var finalTransform = transform * objTransform

            encoder.setRenderPipelineState(pipeline)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&finalTransform, length: MemoryLayout<simd_float4x4>.stride, index: 1)
            encoder.setVertexBytes(&pixelSize, length: MemoryLayout<Float>.stride, index: 2)

            var fragmentColor = Float4(color)

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float4>.stride, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
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

extension Renderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("height: \(size.height) width: \(size.width)")
        print("height: \(view.frame.height) width: \(view.frame.width)")

        aspect = Float(size.width / size.height)
    }

    public func draw(in view: MTKView) {
        let time = CACurrentMediaTime()
        let timeStep = CACurrentMediaTime() - lastFrameTime
        world.update(timeStep: Float(timeStep))
        lastFrameTime = time


        render(world)
    }
}
