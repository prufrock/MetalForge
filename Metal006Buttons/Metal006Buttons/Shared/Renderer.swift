//
//  Drawer.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    let metalBits: MetalBits
    var previous: Double
    var world: RenderableCollection
    var aspect: Float = 1.0
    var screenWidth: Float = 0.0
    var screenHeight: Float = 0.0
    let commandQueue: MTLCommandQueue

    init(metalBits: MetalBits, world: RenderableCollection) {
        self.metalBits = metalBits
        self.previous = CACurrentMediaTime()
        self.world = world
        self.commandQueue = metalBits.device.makeCommandQueue()!

        super.init()

        self.metalBits.view.delegate = self

        self.metalBits.view.clearColor = MTLClearColor(Colors().black)

        mtkView(
            self.metalBits.view,
            drawableSizeWillChange: self.metalBits.view.bounds.size
        )
    }

    private func render(in view: MTKView) {
        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
            fatalError("""
                       Ugh, no command buffer. What the heck!
                       """)
        }

        guard let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("""
                       Dang it, couldn't create a command encoder.
                       """)
        }

        world.render(to: { node in
            guard node.hidden != true else {
                return
            }

            var transform = matrix_identity_float4x4
                * world.cameraSpace(withAspect: aspect)
                // model
                * node.transformation

            let buffer = metalBits.device.makeBuffer(bytes: node.vertices.toFloat4(), length: node.vertices.memoryLength(), options: [])

            encoder.setRenderPipelineState(metalBits.pipelines[.simple]!)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

            var color = node.color

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
            encoder.drawPrimitives(type: node.vertices.primitiveType, vertexStart: 0, vertexCount: node.vertices.count)
        })

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
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("height: \(size.height) width: \(size.width)")
        screenWidth = Float(size.width)
        screenHeight = Float(size.height)
        aspect = Float(size.width / size.height)
        print("aspect ratio: \(aspect)")
    }

    func draw(in view: MTKView) {
        let current = CACurrentMediaTime()
        let delta = current - previous
        previous = current

        world = world.setCameraDimension(top: 1 / aspect, bottom: -1 * (1 / aspect))
        world = world.update(elapsed: delta)
        .setScreenDimensions(height: screenHeight, width: screenWidth)

        render(in: view)
    }
}

extension Renderer {
    func click() {
        world = world.click()
    }

    func click(x: Float, y: Float) {
        world = world.click(x: x, y: y)
    }
}
