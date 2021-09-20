//
//  Drawer.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import Foundation
import MetalKit

class Drawer: NSObject {
    let metalBits: MetalBits
    let vertices: Vertices

    init(metalBits: MetalBits, vertices: Vertices) {
        self.metalBits = metalBits
        self.vertices = vertices

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

        var transform = matrix_identity_float4x4
                // projection
                * float4x4.perspectiveProjection(nearPlane: 0.2, farPlane: 1.0)
                // model
                * float4x4.translate(x: 0.3, y: 0.3, z: 0.0)

        let buffer = metalBits.device.makeBuffer(bytes: vertices.toFloat4(), length: vertices.memoryLength(), options: [])

        encoder.setRenderPipelineState(metalBits.pipelines[.simple]!)
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBytes(&transform, length: MemoryLayout<float4x4>.stride, index: 1)

        var color = Colors().green
        encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
        encoder.drawPrimitives(type: vertices.primitiveType, vertexStart: 0, vertexCount: vertices.count)
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

extension Drawer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
    }

    func draw(in view: MTKView) {
        render(in: view)
    }
}
