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
    var world: GMWorld
    var aspect: Float = 1.0

    init(metalBits: MetalBits, world: GMWorld) {
        self.metalBits = metalBits
        self.previous = CACurrentMediaTime()
        self.world = world

        super.init()

        self.metalBits.view.delegate = self

        self.metalBits.view.clearColor = MTLClearColor(Colors().black)

        mtkView(
            self.metalBits.view,
            drawableSizeWillChange: self.metalBits.view.bounds.size
        )
    }

    private func render(in view: MTKView) {
        guard let commandQueue = metalBits.device.makeCommandQueue() else {
            fatalError("""
                       What?! No comand queue. Come on!
                       """)
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
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

        world.nodes.forEach { node in
            var transform = matrix_identity_float4x4
                    // projection
                    * float4x4.perspectiveProjection(nearPlane: 0.2, farPlane: 1.0)
                    // scale for the aspect ratio
                    * float4x4.scaleY(aspect)
                    // model
                    //* float4x4.translate(x: 0.3, y: 0.3, z: 0.0)
                    * node.transformation

            let buffer = metalBits.device.makeBuffer(bytes: node.vertices.toFloat4(), length: node.vertices.memoryLength(), options: [])

            encoder.setRenderPipelineState(metalBits.pipelines[.simple]!)
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

            var color = Colors().green

            // this probably shouldn't be here but it's currently the easiest place
            // to make it happen.
            if node === world.nodes.last {
                color = Colors().red
            }

            encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
            encoder.drawPrimitives(type: node.vertices.primitiveType, vertexStart: 0, vertexCount: node.vertices.count)
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
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        print("height: \(size.height) width: \(size.width)")
        aspect = Float(size.width / size.height)
        print("aspect ratio: \(aspect)")
    }

    func draw(in view: MTKView) {
        let current = CACurrentMediaTime()
        let delta = current - previous
        previous = current

        world.setCameraDimension(top: 1 / aspect, bottom: -1 * (1 / aspect))
        world.update(elapsed: delta)

        render(in: view)
    }
}

extension Renderer {
    func click() {
        world.click()
    }
}
